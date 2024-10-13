#! /bin/bash
ansible-playbook deploy.yaml --connection=local --extra-vars "environment_file=prod-fic.yaml tasks=ColorStack.yaml color=blue"

