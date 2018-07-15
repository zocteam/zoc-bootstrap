# Welcome to the zoc-bootstrap wiki!

## Install reqs:
1. sudo apt-get install git zip
2. sudo apt install awscli

## Customization:
1. ln -s ~/zeroone/zeroone-cli zeroone-cli
2. ln -s ~/zeroonetest/zeroone-cli zeroone-cli_testnet
3. vi linearize-mainnet.cfg ; edit rpcuser, rpcpass, rpcport and $HOME by real path
4. vi linearize-testnet.cfg ; edit rpcuser, rpcpass, rpcport and $HOME by real path
5. aws configure
6. `git config remote.origin.url https://$GITUSERNAME:$GITTOKEN@github.com/$GITPROJECT/$GITREPONAME`
7. add scanner crontab
```
30 3 * * * cd $HOME/zoc-bootstrap && ./bootstrap.sh >genbootstrap.log 2>&1
```
8. add cleaner crontab 
```
30 2 * * * cd $HOME/zoc-bootstrap && ./cleanbaks.sh >>rmoldbootstrap.log 2>&1
```


## Aws config tips:
Many times `aws s3 cp` fails with error:
```
('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))
```
One possible known workaround is to add `--region buckedregion` at the end of `aws s3 cp` cmd.
Other configs that may help the vps to cope with fast aws s3:
```
cat ~/.aws/config
[default]
aws_access_key_id = foo
aws_secret_access_key = bar
s3 =
  max_concurrent_requests = 5
  max_queue_size = 10
  multipart_threshold = 8MB
  multipart_chunksize = 4MB
  max_bandwidth = 200KB/s
  use_accelerate_endpoint = false
  addressing_style = auto
  payload_signing_enabled = false
```

