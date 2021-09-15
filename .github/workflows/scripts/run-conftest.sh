#!/bin/bash

echo "::group::Terrform Init"
terraform init 
echo "::endgroup::"
echo "::group::Terrform Plan"
terraform plan -out tf.plan
echo "::endgroup::"
echo "::group::Terrform show"
terraform show -json tf.plan > test.json
rm tf.plan
echo "::endgroup::"
conftest test . --update git::https://github.com/cds-snc/opa_checks.git//aws_terraform