# The auth parameter gained a `count` so the secretless v2 path can omit it.
# Without this, every existing v1 consumer plans a destroy-and-recreate of a
# live SecureString on its next apply, purely because the address changed.
moved {
  from = aws_ssm_parameter.sentinel_forwarder_auth
  to   = aws_ssm_parameter.sentinel_forwarder_auth[0]
}
