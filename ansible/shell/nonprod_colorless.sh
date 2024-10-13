#! /bin/bash
ansible-playbook deploy.yaml --connection=local --extra-vars "environment_file=nonprod.yaml tasks=ColorlessHomeBase.yaml color=none"

