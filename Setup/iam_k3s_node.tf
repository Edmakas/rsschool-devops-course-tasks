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

resource "aws_iam_policy" "k3s_node_ecr_pull" {
  name        = "cif-k3s-node-ecr-pull-policy"
  description = "Allow EC2 nodes to pull images from ECR"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:AmazonEC2ContainerRegistryReadOnly"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "k3s_node_ecr_pull" {
  role       = aws_iam_role.k3s_node.name
  policy_arn = aws_iam_policy.k3s_node_ecr_pull.arn
}

resource "aws_iam_instance_profile" "k3s_node" {
  name = "cif-k3s-node-instance-profile"
  role = aws_iam_role.k3s_node.name
}
