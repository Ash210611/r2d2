## Required Software:

This is the required software to run the automation scripts from a macos or linux laptop. 

### Homebrew

run the following in terminal
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
edit your \~./profile to include this at the top:
`export PATH="/usr/local/opt/python/libexec/bin:$PATH"`
to test, run the following:
`brew update`

### Python3 (brew)

run the following:
`brew install python`
to test run:
`python3 -V`


### PIP3 (comes with python3)

should already be installed with python3
to test, run:
`pip3 -V`


### AWS CLI 

run:
`pip3 install awscli`
test:
`aws --version`

In order to configure, you will need to edit your \~/.aws/config and  \~./aws/credentials files

\~/.aws/config :
```
[default]
region = us-east-1
[prod]
region = us-east-1
```

\~/.aws/credentials :
```
[default]
aws_access_key_id = <insert nonprod access key id>
aws_secret_access_key = <insert nonprod secret access key>

[prod]
aws_access_key_id = <insert prod access key id>
aws_secret_access_key = <insert prod secret access key>
```

replace what is in the '< >'s with the aws access keys, you can get them from IAM

### boto3 (from pip3)
run:
`pip3 install boto3`
test:
first run `python3`
in the python cli, run `import boto3`
if there are no errors, it has been successfully installed



### ansible and ansible-playbook (comes from pip3)
run:
`pip3 install ansible`
test:
```
ansible --version
ansible-playbook --version
```

