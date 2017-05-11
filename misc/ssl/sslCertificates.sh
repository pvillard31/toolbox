#!/bin/sh

# generate CSR for the host
openssl req \
  -newkey rsa:2048 -sha256 -nodes \
  -out `hostname`.cert.csr \
  -keyout `hostname`.key.pem \
  -subj "/CN=`hostname -f`"

# generate CSR with SAN

openssl req -new -newkey rsa:2048 -sha256 -subj "/CN=`hostname -f`" -out `hostname -f`.csr -keyout `hostname -f`.key.pem -config <(
cat <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = `hostname -f`

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = my-vip.com
DNS.2 = www.your-vip.com
EOF
)
