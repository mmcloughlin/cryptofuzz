#!/bin/bash -ex

ips="34.214.180.228 35.167.29.72 18.236.144.186 34.216.21.94 52.88.61.154"

for ip in $ips; do
    ssh ubuntu@$ip tail -n 2 /opt/cryptofuzz/target/*/stderr
done
