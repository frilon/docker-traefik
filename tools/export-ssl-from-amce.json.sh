#! /usr/bin/env bash

function setup_env() {
  SCRIPT_DIR=$(dirname "${0}")
  if [[ -s "${SCRIPT_DIR}/../.env" ]]; then
    # shellcheck source=../.env
    source "${SCRIPT_DIR}/../.env"
  fi
}
function check_requirements() {
  for PKG in jq base64; do
    if ! type -p "${PKG}" &>/dev/null; then
      echo "This script needs '${PKG}' to be installed."
      exit 254
    fi
  done
  if [[ -z ${CUSTOM_HOSTNAME} ]] || [[ -z ${CERT_RESOLVER} ]]; then
    echo "'CUSTOM_HOSTNAME' and/or 'CERT_RESOLVER' seems to be empty."
    exit 1
  fi

  if [[ $(ls -n "${SCRIPT_DIR}/../ssl/acme.json" | awk '{print $3}') -ne $(id -u) ]] || [[ $(ls -n "${SCRIPT_DIR}/../ssl/acme.json" | awk '{print $4}') -ne $(id -g) ]]; then
    echo "You are not allowed to read that file."
    exit 1
  fi
}
function print_certificates() {
  for r in $(jq -rc 'keys|.[]' <<<"${j}"); do
    unset ii
    ((++i))
    echo -e "[$i] $r"
    ((++ii))
    echo -n "    [${ii}] "
    jq -rc ".${r}.Certificates[].domain" <<<"${j}" | tr -d "\"{[]}"
  done
  return
}
function store_json_file() {
  j=$(jq '.' "${SCRIPT_DIR}/../ssl/acme.json")
}
function count_resolvers() {
  COUNT_RESOLVERS=$(jq length <<<"${j}")
}
function count_certs_per_resolver() {
  for ((i = 0; i < COUNT_RESOLVERS; ++i)); do
    # mach ein array: certresolver[certs]
    jq -r 'keys as $k | .[$k['"${i}"']].Certificates|length' <<<"${j}"
  done
}
function main() {
  store_json_file
  if [[ -z "${1}" ]]; then
    print_certificates
    exit $?
  fi
  count_resolvers
  count_certs_per_resolver
  if [[ ! "${1}" -le ${COUNT_RESOLVERS} ]]; then
    jq -r 'keys as $k | .[$k['"${1}"']].Certificates[].domain.main' <<<"${j}"
  fi

}

setup_env
check_requirements
main "$@"

### Manually export:
# jq -r '.cloudflare.Certificates[] | select(.domain.main=="fammoldenhauer.de") | .certificate' tools/acme.json | base64 -d
# jq -r '.cloudflare.Certificates[] | select(.domain.main=="fammoldenhauer.de") | .key' tools/acme.json | base64 -d
