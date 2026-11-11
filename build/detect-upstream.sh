#!/usr/bin/env bash
# Prints the latest upstream Fedora 45 cloud image version on stdout
# (e.g. 45-1.4), parsed from the directory listing at
#   https://dl.fedoraproject.org/pub/fedora/linux/releases/45/Cloud/x86_64/images/
# Runs in the upstream-watch reusable workflow (no KVM needed): keep it
# portable bash + curl + grep + sort only.

set -euo pipefail

URL='https://dl.fedoraproject.org/pub/fedora/linux/releases/45/Cloud/x86_64/images/'

listing=$(curl -fsL "$URL")
if [[ -z "$listing" ]]; then
  echo "::error::could not fetch $URL" >&2
  exit 1
fi

latest=$(printf '%s\n' "$listing" \
  | grep -oE 'Fedora-Cloud-Base-Generic-45-[0-9]+\.[0-9]+\.x86_64\.qcow2' \
  | sed -E 's#Fedora-Cloud-Base-Generic-(45-[0-9]+\.[0-9]+)\.x86_64\.qcow2#\1#' \
  | sort -uV \
  | tail -n1)

if [[ -z "$latest" ]]; then
  echo "::error::no Fedora 45 cloud image found in $URL" >&2
  exit 1
fi

printf '%s\n' "$latest"
