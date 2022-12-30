#!/usr/bin/env bash

curl -Os -L https://github.com/projectcalico/calicoctl/releases/download/v3.17.0/calicoctl
chmod +x calicoctl
mv -f calicoctl /usr/local/bin
mkdir /etc/calico