resource "aws_iam_user" "kops" {
  name = "kops${var.stage}"
}

resource "aws_iam_access_key" "kops" {
  user = aws_iam_user.kops.name
}

resource "aws_iam_user_policy_attachment" "kops_usr_pol_1" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "kops_usr_pol_2" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_user_policy_attachment" "kops_usr_pol_3" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "kops_usr_pol_4" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_user_policy_attachment" "kops_usr_pol_5" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}
resource "aws_iam_user_policy_attachment" "kops_usr_pol_6" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
resource "aws_iam_user_policy_attachment" "kops_usr_pol_7" {
  user       = aws_iam_user.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}


resource "aws_s3_bucket" "kops_config_bucket" {
  bucket = var.kops_state
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    name = "kops Cluster Configuration Bucket"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.kops_config_bucket.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
				"Sid": "Allow kops user access to k8s cluster configuration bucket",
				"Effect": "Allow",
				"Principal": {
						"AWS": [
								"${aws_iam_user.kops.arn}"
						]
				},
				"Action": [
						"s3:GetBucketLocation",
						"s3:ListBucket",
						"s3:GetObject",
						"s3:PutObject"
				],
				"Resource": [
						"${aws_s3_bucket.kops_config_bucket.arn}",
						"${aws_s3_bucket.kops_config_bucket.arn}/*"
				]
		}
	]
}
POLICY
}