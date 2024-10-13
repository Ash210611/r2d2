# Ansible 

## About
This is the automation to create an environment from scratch. Creates VPC, ImageBuilders, Fleets, Logging servers, Jumpbox, Proxy Servers. What it does not do:

 - Does not automate creation of an AppStream image. Needs to be done semi-manually. This is due to an unavoidable roadblock
 - Does not automate installation of software on the logging server. This can be completed, but has not been done yet.


There are two parts to the architecture, colored and colorless, in order to support blue/green deployment

Colorless architecture remains constant between blue/green cycles. 
	HomebaseVPC
	Logging Server
	Jumpbox
	Image Builder
	Hosted Zone
Colored architecture is either blue or green, and is everything else
	Fleets
	Proxy Servers
	Proxy Region Architecture 

* lists above not exhaustive

## How To Use
From the ansible directory, run the appropriate script in the shell directory

./shell/prodfic.sh # for example

If it does not call or errors out immediately, it may have to do with the folder level you are on and relative paths. Ansible needs to find all the files, and references things in other folders. 

You can also call ansible directly:

ansible-playbook playbooks/deploy.yaml --connection=local --extra-vars "environment_file=nonprod.yaml tasks=ColorStack.yaml color=blue"

The first part, "ansible-playbook playbooks/deploy.yaml --connection=local --extra-vars" is always the same. 

The extra variables portion is what tells ansible what configurations to use. 

environment_file: This is what contains the environment variables for the environment you are building. 

task: The tasks we are going to do. Options are:
	ColorlessHomeBase.yaml
		This is the colorless architecture
	ColorStack.yaml
		All the architecture that goes in the homebase that is colored
	Egress Stack
		The egress region, including the nat gateway and proxy servers. Are colored. 


### playbooks
Contains the ansible playbooks to call the cloudformation and do other configurations, such as uploading configs to s3 buckets

	ColorlessHomeBase.yaml
		This is the colorless architecture
	ColorStack.yaml
		All the architecture that goes in the homebase that is colored
	Egress Stack
		The egress region, including the nat gateway and proxy servers. Are colored. 



### shell
Contains shell scripts to call ansible. Shortcuts so you don't have to keep writing out the same command over and over. You don't need to use these to cerate the environment, but they make it easier. 


### vars
envmapping: configurations common across all environments, such as region names to region codes, and the secure image ids. 

The other files are environment specific configurations, such as the subnet IP ranges and instance sizes.

### deploy.yaml
The base deploy file. All it does is load the tasks and environment variables, and sets it moving forward. 

## TO DO

To Do List:

- Because of EnvMapping, we may not need certain parts of the cfn 
- CLEAN S3 BUCKETS AT THE END
- Clean ansible by serperating it more
- Looks like VPCPeeringConnection can be tagged in cloudformation so now we can remove a huge chunk of the anisble that only tags the VPCPeeringConnection
- Create TODO List that outputs manual changes
