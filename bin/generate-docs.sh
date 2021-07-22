#!/bin/bash


function generate_docs  {
  echo "📝 Generating docs for module $1"
  docker run -v "$PWD/$1":/tmp/terraform quay.io/terraform-docs/terraform-docs:latest /tmp/terraform -c /tmp/terraform/.terraform-docs.yml > "$1/README.md"
}

generate_docs "user_login_alarm"
echo "✅ Done generating docs"
