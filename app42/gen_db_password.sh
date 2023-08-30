#!/bin/bash
echo -n "$(openssl rand -base64 24)" > db_password
chmod 600 db_password
