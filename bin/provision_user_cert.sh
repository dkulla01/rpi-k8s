#!/usr/bin/bash

# following instructions for creating a user certificate
# from this blog post: https://cloudhero.io/creating-users-for-your-kubernetes-cluster
# this will create a dan.crt certificate

KUBE_CA_DIR='/etc/kubernetes/pki'
USER_CERTIFICATE_DIR="${KUBE_CA_DIR}/user_certs"
BASH_CUSTOM_VARIABLES_FILE='.bash_custom_variables'

sudo mkdir -p "$USER_CERTIFICATE_DIR"
sudo cp "${KUBE_CA_DIR}/ca.*" "$USER_CERTIFICATE_DIR"

#Generate a dan.rsa rsa key
sudo openssl genrsa -out "${USER_CERTIFICATE_DIR}/dan.key" 2048

#Generate a certificate signing request.
# - dan is the user (cert common name name), adminusers is the group
sudo openssl req -new \
-key "${USER_CERTIFICATE_DIR}/dan.key" \
-out "${USER_CERTIFICATE_DIR}/dan.csr" \
-subj "/CN=dan/O=adminusers"

# use the CSR to create an x509 cert
sudo openssl x509 -req \
-in "${USER_CERTIFICATE_DIR}/dan.csr" \
-CA "${USER_CERTIFICATE_DIR}/ca.crt" \
-CAkey "${USER_CERTIFICATE_DIR}/ca.key" \
-CAcreateserial \
-in "${USER_CERTIFICATE_DIR}/dan.crt" \
-days 3650

# remove intermediate output
sudo rm -f "${USER_CERTIFICATE_DIR}/dan.csr"  "${USER_CERTIFICATE_DIR}/ca.srl"

if [ ! -f "$HOME/${BASH_CUSTOM_VARIABLES}" ]; then
  touch "$HOME/${BASH_CUSTOM_VARIABLES}"
fi

if ! grep -q CA_CRT_BASE64; then
 # let the base64 for the certificates get interpreted when we source the file,
 # not when we write to it
 # shellcheck disable=SC2016
 { echo 'export CA_CRT_BASE64=$(base64 "${USER_CERTIFICATE_DIR}/ca.crt")'; \
 echo 'export CLIENT_CRT_BASE64=$(base64 "${USER_CERTIFICATE_DIR}/dan.crt")'; \
 echo 'export CLIENT_KEY_BASE64=$(base64 "${USER_CERTIFICATE_DIR}/dan.kry")'; } >> "${HOME}/${BASH_CUSTOM_VARIABLES_FILE}"
fi