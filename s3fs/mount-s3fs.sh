#!/bin/bash
s3fs ulysses-bucket:/ ~/S3/ulysses-bucket/ -o umask=0007
