#!/bin/bash

dmg pool create --size=2GB tank

dmg pool list

RGW=1 ../src/vstart.sh -d

daos cont list tank

s3cmd --no-ssl mb s3://testbucket

s3cmd --no-ssl ls

dfuse -m /tmp/dfuse --pool tank --cont testbucket

cd /tmp/dfuse

tree

echo "Test file" > /tmp/testfile

head -c 50KB /dev/urandom > /tmp/50KB

s3cmd --no-ssl put /tmp/testfile s3://testbucket/test/foo/bar/file

s3cmd --no-ssl put /tmp/50KB s3://testbucket/test/foo/baz/50KB

tree

cat /tmp/dfuse/test/foo/bar/file

md5sum /tmp/50KB /tmp/dfuse/test/foo/baz/50KB
