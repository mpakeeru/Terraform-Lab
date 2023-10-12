#creating IAM policy for S3 full access
resource "aws_iam_role" "vprofile-instance-role" {
  name = "vprofile-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "vprofile-instance-role"
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role_policy" "vprofile-instance-s3-policy" {
    name = "vprofile-instance-s3-policy"
    role = "${aws_iam_role.vprofile-instance-role.id}"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
            Effect = "Allow",
            Action = [
                "s3:*",
                "s3-object-lambda:*"
            ],
            Resource = "*"
        }
    ]
})


}
#attch role to instance profile
resource "aws_iam_instance_profile" "vprofile-instance-profile" {
    name = "vprofile-instance-profile"
    role = aws_iam_role.vprofile-instance-role.name
  
}
#creating IAM role and policy for codedeploy full access
resource "aws_iam_role" "vprofile-codedeploy-role" {
  name = "vprofile-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "vprofile-codedeploy-role"
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role_policy" "vprofile-codedeploy-policy" {
    name = "vprofile-codedeploy-policy"
    role = "${aws_iam_role.vprofile-codedeploy-role.id}"
    policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Action = "codedeploy:*",
            Effect = "Allow",
            Resource = "*"
        },
        {
            Sid = "CodeStarNotificationsReadWriteAccess",
            Effect = "Allow",
            Action = [
                "codestar-notifications:CreateNotificationRule",
                "codestar-notifications:DescribeNotificationRule",
                "codestar-notifications:UpdateNotificationRule",
                "codestar-notifications:DeleteNotificationRule",
                "codestar-notifications:Subscribe",
                "codestar-notifications:Unsubscribe"
            ],
            Resource = "*",
            Condition = {
                StringLike = {
                    "codestar-notifications:NotificationsForResource": "arn:aws:codedeploy:*"
                }
            }
        },
        {
            Sid = "CodeStarNotificationsListAccess",
            Effect = "Allow",
            Action = [
                "codestar-notifications:ListNotificationRules",
                "codestar-notifications:ListTargets",
                "codestar-notifications:ListTagsforResource",
                "codestar-notifications:ListEventTypes"
            ],
            Resource = "*"
        },
        {
            Sid = "CodeStarNotificationsSNSTopicCreateAccess",
            Effect = "Allow",
            Action = [
                "sns:CreateTopic",
                "sns:SetTopicAttributes"
            ],
            Resource = "arn:aws:sns:*:*:codestar-notifications*"
        },
        {
            Sid = "CodeStarNotificationsChatbotAccess",
            Effect = "Allow",
            Action = [
                "chatbot:DescribeSlackChannelConfigurations"
            ],
            Resource = "*"
        },
        {
            Sid = "SNSTopicListAccess",
            Effect = "Allow",
            Action = [
                "sns:ListTopics"
            ],
            Resource = "*"
        }
    ]
})
  
}