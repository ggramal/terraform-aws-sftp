resource "aws_iam_role" "sftp_server_role" {
  name = "sftp-server-${var.sftp_server.name}-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "sftp_server_policy" {
  name = "sftp-server-${var.sftp_server.name}-role-policy"
  role = "${aws_iam_role.sftp_server_role.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = var.sftp_server.identity_provider_type
  logging_role           = aws_iam_role.sftp_server_role.arn

  tags = var.sftp_server.tags
}

