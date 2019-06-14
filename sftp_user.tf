resource "aws_iam_role" "sftp_user_role" {
  count = length(var.sftp_users)
  name  = "sftp-user-${var.sftp_users[count.index].name}-role"

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

data "aws_iam_policy_document" "sftp_user_iam_policy_document" {
  count = length(var.sftp_users)

  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = formatlist("%s*", var.sftp_users[count.index].s3_bucket_arns)
  }
}


resource "aws_iam_role_policy" "sftp_user_policy" {
  count = length(var.sftp_users)
  name = "sftp-user-${var.sftp_users[count.index].name}-role-policy"
  role = aws_iam_role.sftp_user_role[count.index].id

  policy = data.aws_iam_policy_document.sftp_user_iam_policy_document[count.index].json
}

resource "aws_transfer_user" "sftp_user" {
  count = length(var.sftp_users)
  server_id = aws_transfer_server.sftp_server.id
  user_name = var.sftp_users[count.index].name
  role = aws_iam_role.sftp_user_role[count.index].arn
  home_directory = "/${replace(var.sftp_users[count.index].s3_bucket_arns[0], "arn:aws:s3:::", "")}"
}

resource "aws_transfer_ssh_key" "sftp_user_ssh" {
  count = length(var.sftp_users)
  server_id = "${aws_transfer_server.sftp_server.id}"
  user_name = aws_transfer_user.sftp_user[count.index].user_name
  body = var.sftp_users[count.index].public_key
}
