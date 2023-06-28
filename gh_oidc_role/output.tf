output "roles" {
  description = "Returns all the roles created accessed by the name passed in to the module."
  value       = { for r in aws_iam_role.this : r.name => r }
}

output "certificate_thumbprints" {
  description = "Returns the thumbprints of the OIDC provider."
  value       = data.tls_certificate.thumprint.certificates.*.sha1_fingerprint
}
