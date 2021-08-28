#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

function generate_docs  {
  echo "📝 Generating docs for module $1"
  terraform-docs markdown "$SCRIPT_DIR/../$1" > "$SCRIPT_DIR/../$1/README.md"
}

generate_docs "user_login_alarm"
generate_docs "vpc"
generate_docs "rds"
generate_docs "S3"
generate_docs "S3_log_bucket"
generate_docs "monolith"
echo "✅ Done generating docs"
