output "role_arn" {
  value       = aws_iam_role.datafy.arn
  description = "ARN of the IAM role for Datafy.io."
}

output "role_name" {
  value       = aws_iam_role.datafy.name
  description = "Name of the IAM role for Datafy.io."
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.datafy.arn
  description = "ARN of the IAM OIDC provider."
}
