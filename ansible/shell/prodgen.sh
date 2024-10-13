#! /bin/bash
ansible-playbook deploy.yaml --connection=local --extra-vars "environment_file=prod-gen.yaml tasks=ColorlessHomeBase.yaml color=none"

ansible-playbook deploy.yaml --connection=local --extra-vars "environment_file=prod-gen.yaml tasks=ColorStack.yaml color=blue"

