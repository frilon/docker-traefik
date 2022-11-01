#! /usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

for PKG in jq base64; do
    if ! type -p "${PKG}" &>/dev/null; then
        echo "This script needs '${PKG}' to be installed."
        exit 254
    fi
done
if [[ -s "${SCRIPT_DIR}/../.env" ]]; then
    # shellcheck source=../.env
    source "${SCRIPT_DIR}/../.env"
fi
if [[ -z ${CUSTOM_HOSTNAME} ]] || [[ -z ${CERT_RESOLVER} ]]; then
    echo "'CUSTOM_HOSTNAME' and/or 'CERT_RESOLVER' seems to be empty."
    exit 1
fi

if [[ $(ls -n "${SCRIPT_DIR}/../ssl/acme.json" | awk '{print $3}') -ne $(id -u) ]] || [[ $(ls -n "${SCRIPT_DIR}/../ssl/acme.json" | awk '{print $4}') -ne $(id -g) ]]; then
    echo "You are not allowed to read that file."
    exit 1
fi

jq -r ".${CERT_RESOLVER}.Certificates[] | .certificate" <"${SCRIPT_DIR}/../ssl/acme.json" | base64 -d | tee "${SCRIPT_DIR}/../ssl/${CUSTOM_HOSTNAME}.crt.pem"
jq -r ".${CERT_RESOLVER}.Certificates[] | .key" <"${SCRIPT_DIR}/../ssl/acme.json" | base64 -d | tee "${SCRIPT_DIR}/../ssl/${CUSTOM_HOSTNAME}.key.pem"
