#creating codedeploy role and policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "codedeploy-role1" {
  name               = "codedeploy-role1"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy-role1.name
}

#creating codedeploying application
resource "aws_codedeploy_app" "vprofile" {
    name = "vprofile"
  
}
resource "aws_codedeploy_deployment_group" "vproile-codedeployment-group" {
    app_name = aws_codedeploy_app.vprofile.name
    deployment_group_name = "vprofile-codedeployment-group"
    service_role_arn = aws_iam_role.codedeploy-role1.arn
    deployment_config_name = "CodeDeployDefault.OneAtATime"
    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "IN_PLACE"
    }
    load_balancer_info {
      target_group_info {
        name = aws_lb_target_group.vprofile-targetgroup.name

      }
    }
    autoscaling_groups = ["${aws_autoscaling_group.vprofile-asg.name}"]
  
}