variable "sftp_server" {
  type = object({
    name                   = string
    identity_provider_type = string
    tags                   = map(string)
  })
}

variable "sftp_users" {
  type = list(object({
    name           = string
    s3_bucket_arns = list(string)
    public_key     = string
  }))
}
