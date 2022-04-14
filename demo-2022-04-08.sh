#!/bin/bash

# Basics

echo "Test file" > /tmp/testfile

head -c 50KB /dev/urandom > /tmp/50KB

head -c 51KB /dev/urandom > /tmp/51KB


s3cmd mb s3://testbucket


s3cmd put /tmp/testfile s3://testbucket/test/foo/bar/file

s3cmd put /tmp/50KB s3://testbucket/test/foo/baz/50KB

s3cmd put /tmp/51KB s3://testbucket/51KB


s3cmd ls s3://testbucket


dfuse -m /tmp/dfuse --pool tank --cont testbucket

cd /tmp/dfuse

tree


s3cmd get s3://testbucket/test/foo/bar/file /tmp/testfile-get --force

s3cmd get s3://testbucket/test/foo/baz/50KB /tmp/50KB-get --force

s3cmd get s3://testbucket/51KB /tmp/51KB-get --force


cat /tmp/testfile-get


md5sum /tmp/50KB /tmp/50KB-get /tmp/dfuse/test/foo/baz/50KB

md5sum /tmp/51KB /tmp/51KB-get /tmp/dfuse/51KB


s3cmd rm s3://testbucket/51KB

tree

s3cmd ls s3://testbucket

cd ~
fusermount3 -u /tmp/dfuse





# Multipart

head -c 100MB /dev/urandom > /tmp/100MB

head -c 99MB /dev/urandom > /tmp/99MB

head -c 98MB /dev/urandom > /tmp/98MB


s3cmd put /tmp/100MB s3://testbucket/100MB


s3cmd ls s3://testbucket


s3cmd get s3://testbucket/100MB /tmp/100MB-get --force


md5sum /tmp/100MB /tmp/100MB-get /tmp/dfuse/100MB



s3cmd put /tmp/99MB s3://testbucket/99MB


s3cmd multipart s3://testbucket


s3cmd listmp s3://testbucket/99MB


mkdir /tmp/metadata

dfuse -m /tmp/metadata --pool tank --cont _METADATA

cd /tmp/metadata

tree


s3cmd put /tmp/99MB s3://testbucket/99MB --upload-id=


s3cmd get s3://testbucket/99MB /tmp/99MB-get --force


md5sum /tmp/99MB /tmp/99MB-get


s3cmd put /tmp/98MB s3://testbucket/98MB


s3cmd multipart s3://testbucket


tree


s3cmd abortmp s3://testbucket/98MB


s3cmd multipart s3://testbucket


cd ~

fusermount3 -u /tmp/metadata





# Versioning

s3cmd mb s3://testbucket-v


head -c 50KB /dev/urandom > /tmp/50KBv1

head -c 50KB /dev/urandom > /tmp/50KBv2

head -c 50KB /dev/urandom > /tmp/50KBv3


s3cmd put /tmp/50KBv1 s3://testbucket-v/50KB

s3cmd put /tmp/50KBv2 s3://testbucket-v/50KB

s3cmd put /tmp/50KBv3 s3://testbucket-v/50KB


s3cmd ls s3://testbucket-v


s3cmd get s3://testbucket-v/50KB /tmp/50KB-get --force


md5sum /tmp/50KBv1 /tmp/50KBv2 /tmp/50KBv3 /tmp/50KB-get


aws s3api list-object-versions --endpoint-url http://localhost:8000 --bucket testbucket-v --delim / | jq '.Versions[] | "\(.Key) \(.VersionId)"'



aws s3api put-bucket-versioning --endpoint-url http://localhost:8000 --bucket testbucket-v --versioning-configuration Status=Enabled


s3cmd put /tmp/50KBv1 s3://testbucket-v/50KB

s3cmd put /tmp/50KBv2 s3://testbucket-v/50KB

s3cmd put /tmp/50KBv3 s3://testbucket-v/50KB


s3cmd ls s3://testbucket-v


aws s3api list-object-versions --endpoint-url http://localhost:8000 --bucket testbucket-v --delim / | jq '.Versions[] | "\(.Key) \(.VersionId)"'


aws s3api get-object /tmp/50KB-get --key 50KB --endpoint-url http://localhost:8000 --bucket testbucket-v --version-id


md5sum /tmp/50KBv1 /tmp/50KBv2 /tmp/50KBv3 /tmp/50KB-get


aws s3api put-bucket-versioning --endpoint-url http://localhost:8000 --bucket testbucket-v --versioning-configuration Status=Suspended


s3cmd put /tmp/50KBv1 s3://testbucket-v/50KBsus

s3cmd put /tmp/50KBv2 s3://testbucket-v/50KBsus

s3cmd put /tmp/50KBv3 s3://testbucket-v/50KBsus


aws s3api list-object-versions --endpoint-url http://localhost:8000 --bucket testbucket-v --delim / | jq '.Versions[] | "\(.Key) \(.VersionId)"'


aws s3api delete-objects --endpoint-url http://localhost:8000 --bucket testbucket-v --delete 'Objects=[{Key=50KB,VersionId=}]'


aws s3api list-object-versions --endpoint-url http://localhost:8000 --bucket testbucket-v --delim / | jq '.Versions[] | "\(.Key) \(.VersionId)"'


dfuse -m /tmp/dfuse --pool tank --cont testbucket-v

tree /tmp/dfuse


fusermount3 -u /tmp/dfuse

