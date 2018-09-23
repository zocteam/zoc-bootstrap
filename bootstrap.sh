#!/bin/bash
s3cmd="aws s3"
s3name="files.01coin.io"
s3bucket="s3://$s3name/"
s3https="https://$s3name/"
file="bootstrap.dat"
file_zip="$file.zip"
file_gz="$file.tar.gz"
file_sha256="sha256.txt"
file_md5="md5.txt"
header=`cat header.md`
footer=`cat footer.md`

# pass network name as a param
do_the_job() {
  network=$1
  blocks=$2
  mkdir -p bootstrap$network$blocks
  date=`date -u`
  date_fmt=`date -u +%Y-%m-%d`
  s3networkPath="$s3bucket$network/"
  s3currentPath="$s3networkPath$date_fmt/"
  s3currentUrl="$s3https$network/$date_fmt/"
  linksFile="links-$network.md"
  prevLinks=`head $linksFile`
  echo "$network job - Starting..."
  # process blockchain
  ./linearize-hashes.py linearize-$network.cfg > hashlist.txt
  ./linearize-data.py linearize-$network.cfg
  # compress
  zip $file_zip $file
  GZIP=-9 tar -cvzf $file_gz $file
  # calculate checksums
  sha256sum $file > $file_sha256
  sha256sum $file_zip >> $file_sha256
  sha256sum $file_gz >> $file_sha256
  md5sum $file > $file_md5
  md5sum $file_zip >> $file_md5
  md5sum $file_gz >> $file_md5
  # remove old latest
  $s3cmd rm $s3networkPath$file_zip
  $s3cmd rm $s3networkPath$file_gz
  $s3cmd rm $s3networkPath$file_sha256
  $s3cmd rm $s3networkPath$file_md5
  # store
  $s3cmd cp $file_zip $s3currentPath$file_zip --acl public-read
  $s3cmd cp $file_gz $s3currentPath$file_gz --acl public-read
  $s3cmd cp $file_sha256 $s3currentPath$file_sha256 --acl public-read
  $s3cmd cp $file_md5 $s3currentPath$file_md5 --acl public-read
  $s3cmd cp $file_zip $s3networkPath$file_zip --acl public-read
  $s3cmd cp $file_gz $s3networkPath$file_gz --acl public-read
  $s3cmd cp $file_sha256 $s3networkPath$file_sha256 --acl public-read
  $s3cmd cp $file_md5 $s3networkPath$file_md5 --acl public-read
  # update docs
  url_zip=$s3currentUrl$file_zip
  url_gz=$s3currentUrl$file_gz
  url_sha256=$s3currentUrl$file_sha256
  url_md5=$s3currentUrl$file_md5
  size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
  size_gz=`ls -lh $file_gz | awk -F" " '{ print $5 }'`
  newLinks="Block $blocks: $date [zip]($url_zip) ($size_zip) [gz]($url_gz) ($size_gz) [SHA256]($url_sha256) [MD5]($url_md5)\n\n$prevLinks"
  echo -e "$newLinks" > $linksFile
  mv $file $file_zip $file_gz $file_sha256 $file_md5 hashlist.txt bootstrap$network$blocks/
  echo -e "#### For $network:\n\n$newLinks\n\n" >> README.md
  # clean up old files
  keepDays=7
  scanDays=30
  oldFolders=$($s3cmd ls $s3networkPath | grep -oP '[0-9]*-[0-9]*-[0-9]*')
  while [ $keepDays -lt $scanDays ]; do
    loopDate=$(date -u -d "now -"$keepDays" days" +%Y-%m-%d)
    found=$(echo -e $oldFolders | grep -oP $loopDate)
    if [ "$found" != "" ]; then
      echo "found old folder $found, deleting $s3networkPath$loopDate/ ..."
      $s3cmd rm $s3networkPath$loopDate --recursive
    fi
    let keepDays=keepDays+1
  done
  echo "$network job - Done!"
}

# fill the header
echo -e "$header\n" > README.md

# mainnet
#cat ~/.zeroonecore/blocks/blk0000* > $file
blocks=`./zeroone-cli getblockcount`
do_the_job mainnet $blocks

# testnet
#cat ~/.zeroonetest/testnet3/blocks/blk0000* > $file
blocks=`./zeroone-cli_testnet -datadir=$HOME/.zeroonetest getblockcount`
do_the_job testnet $blocks

# finalize with the footer
echo -e "$footer" >> README.md

# push to github
git add *.md
git commit -m "$date - autoupdate"
git push
