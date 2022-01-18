#!/bin/bash
hostnamectl set-hostname web2
echo "web2" > /usr/share/nginx/html/index.html
