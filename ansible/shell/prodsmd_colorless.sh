#! /bin/bash
ansible-playbook deploy.yaml --connection=local --extra-vars "environment_file=prod-smd.yaml tasks=ColorlessHomeBase.yaml color=none"
