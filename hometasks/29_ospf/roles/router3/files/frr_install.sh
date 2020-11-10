#!/bin/bash

FRRVER="frr-stable"

# add RPM repository on CentOS 8
curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el8.noarch.rpm
yum install ./$FRRVER* -y

# install FRR
yum install frr frr-pythontools -y