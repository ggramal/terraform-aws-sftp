# terraform-aws-sftp
Terraform module for deploying and managing [AWS Transfer for SFTP](https://docs.aws.amazon.com/transfer/index.html) service

## Terrfarom versions
Currently module supports only `~> 0.12` versions of terraform

## Usage
Create an sftp server with public endpoint

```
module "sftp" {
  source = "github.com/ggramal/terraform-aws-sftp"

  sftp_server = {
    name                   = "some-sftp-server"
    identity_provider_type = "SERVICE_MANAGED"
    tags                   = {}
  }

  sftp_users = [
    {
      name           = "some-user1"
      public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGGxXQM2J8N+N4/MScKX4lLms+lA68+ltzJmmRFU1bCH/EWN2IQCOjmmnM5gAGK6oeeM58Y4EE71q+AGlWv2nbuvvuI4bwLYKgqJ3/xotkScNzHDPa03vRLG4HWaiF/cmqo/pLsQuAdoMrCGcfTWFJxGMgZw+taT3p+oR6Lw85vVVHwakWJhBu+qb8KLoJWWQnWNOUBm6jBFE10st3AZP3daeZxruqDzFI/wnmUEEwQ8Uq1HlsqzT7dZfm5ok3bhSr/LclOwaiPJikgU+NQm7ANLwtEByPdcAu240MB5BLVyuIMImsXl8Rclsl2Kfg87JShTmB/qSLOaTbrBxU0Fpd"
      s3_bucket_arns = [
        'arn:aws:s3:::some-s3-bucket1',
        'arn:aws:s3:::some-s3-bucket2',
      ]
    },
    {
      name           = "some-user2"
      public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDL2hNKG2vYuv9zc0KmMJMYJ7c2E1nMSLVNBXphsMDa2xM431LfX4c3wjdkqXxchaSNV2vNDqvTPXHO9XPpjPWAno+2Ez8Hnt44cGCi+ksn8CgLkaWq20k5K+vtOckV/ZkizGREy6NfXa7tgt9uu28BnqHKGmsiLGL0yQnb/jEWiuu0h3NyagV1t2lcEDlb2G8s6XTb9lQr/teFhHLk0rNYfiWPyaSy2BsD9EkoC80kJBo6ZIk7t8MABDTCASg9LZAtZc8Yq6nyFQHhyVUmAAj0NPK8A8+8CIclNkezU2XP7OAEeN8KtTBkofK9diZt+gI2y1BcfIhY12SglMvzpwL7"
      s3_bucket_arns = [
        'arn:aws:s3:::some-s3-bucket1',
      ]
    },
  ]
}
```
## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| sftp_server | sftp server definition |object | - | yes
| sftp_users | sftp users list |list(object) | null | no
### sftp_server
|Field Name |Field Description |Field Type |
|------|-------------|:----:|
| name | the name of the AWS transfer sftp server |  string
| identity_provider_type | The mode of authentication enabled for this service. Only `SERVICE_MANAGED` value is supported now  |list(object)
| tags | a map that represents AWS transfer sftp server tags | map(string)
### sftp_users
|Field Name |Field Description |Field Type |
|------|-------------|:----:|
| name | user name of AWS transfer sftp server |  string
| public_key | ssh public key of the user |string
| s3_bucket_arns | a list of s3 bucket arns to which user has rw permissions | list(string)

**NOTE** The first element in `s3_bucket_arns` list will be the home directory of the user
## IAM policies and roles

## Roles
This module creates a set of roles with `transfer.amazonaws.com` trusted entity - one for `sftp_server` and one for each user object in `sftp_users` list
#### Role names
```
sftp-server-${var.sftp_server.name}-role
sftp-user-${var.sftp_users[count.index].name}-role
```
## Policies
This module creates a set of policies which are attached to corresponding roles

`sftp-server-${var.sftp_server.name}-role-policy` - is a policy that enables logging on `AWS transfer sftp` service. This policy grants full access to CloudWatch Logs.

`sftp-user-${var.sftp_users[count.index].name}-role` - is a policy that grants each user in `sftp_users` rw permission to buckets specified in `s3_bucket_arns` for that user.
