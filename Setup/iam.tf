resource "aws_iam_role" "github_actions" {
  name = "GithubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.GITHUB_REPO}/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "route53" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

# resource "aws_iam_policy" "github_actions_ssm_getparameter" {
#   name        = "github-actions-ssm-getparameter"
#   description = "Allow GithubActionsRole to get k3s.yaml from SSM Parameter Store"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ssm:GetParameter"
#         ],
#         Resource = "arn:aws:ssm:us-west-2:${var.AWS_ACCOUNT_ID}:parameter/rsschool/k3s-yaml"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "github_actions_ssm_getparameter" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions_ssm_getparameter.arn
# }

#######  Creating aws_iam_instance_profile

resource "aws_iam_role" "k3s_node" {
  name = "cif-k3s-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "k3s_node_ssm" {
  name        = "cif-k3s-node-ssm-policy"
  description = "Allow EC2 node-1 to put k3s.yaml to SSM Parameter Store"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters",
          "ssm:ListTagsForResource"
        ],
        Resource = "arn:aws:ssm:*:*:parameter/*k3s-yaml"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "k3s_node_ssm" {
  role       = aws_iam_role.k3s_node.name
  policy_arn = aws_iam_policy.k3s_node_ssm.arn
}

resource "aws_iam_instance_profile" "k3s_node" {
  name = "cif-k3s-node-instance-profile"
  role = aws_iam_role.k3s_node.name
}
