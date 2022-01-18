#!/bin/bash
hostnamectl set-hostname web1
echo "web1" > /usr/share/nginx/html/index.html
