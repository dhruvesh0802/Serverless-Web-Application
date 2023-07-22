# module "iam_iam-user" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-user"
#   version = "5.14.4"
#   # insert the 1 required variable here
#   name = "dhruvesh-git-user"
  
# }

resource "aws_iam_user" "dhruvesh_sheladiya_IAM_user" {
  name = "Dhruvesh-Sheladiya-User"
}

resource "aws_iam_user_policy_attachment" "dhruvesh_sheladiya_user_policy_attachment" {
  user       = aws_iam_user.dhruvesh_sheladiya_IAM_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

resource "aws_iam_service_specific_credential" "example" {
  service_name = "codecommit.amazonaws.com"
  user_name    = aws_iam_user.dhruvesh_sheladiya_IAM_user.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}
#IAM role providing read-only access to CodeCommit
resource "aws_iam_role" "amplify-codecommit" {
  name                = "Dhruvesh-AmplifyCodeCommit"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"]
}

data "aws_iam_policy_document" "assume_role2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name                = "DhruveshWildRydes"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role2.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name = "dynamodb_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["dynamodb:PutItem"]
          Effect   = "Allow"
          Resource = "arn:aws:dynamodb:us-east-1:587172484624:table/Dhruvesh-dynamodb"
        },
      ]
    })
  }
}

