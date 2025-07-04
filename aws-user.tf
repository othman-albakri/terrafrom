provider "aws" {
  region = "me-south-1"
}
# Creates an IAM user in AWS
resource "aws_iam_user" "admin-user" {
     # The name of the IAM user. This must be unique within your AWS account.
     
    name = "admin-user"
      # The path for the IAM user. Use "/" if you don't need a custom path.
      # path like a folder structure for organizing IAM resources.
      #arn:aws:iam::123456789012:user/developers/developer1
    path = "/"  
    
    tags = {
    Description = "DevOps Admin User"
    Team        = "DevOps"
  }
}
# Attach a login profile to set a password for the user
resource "aws_iam_user_login_profile" "admin_user_password" {
  user     = aws_iam_user.admin-user.name
  #password = "9-J-HU9o@_j@Ek*Jfu23p2Zwgr" # Replace with a secure password
  password_reset_required = true      # Forces the user to reset their password on first login
}

# Create custom read-only policy from file
resource "aws_iam_policy" "readonly_all" {
  name        = "ReadOnlyAllPolicy"
  description = "Read-only access to all AWS resources"
  policy      = file("readonly_all_policy.json")
  tags = {
    Name        = "ReadOnlyAllPolicy"
    Environment = "dev"
    CreatedBy   = "terraform"
    Purpose     = "Read-only access for auditing"
  }
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "readonly_all_attach" {
  user       = aws_iam_user.admin-user.name
  policy_arn = aws_iam_policy.readonly_all.arn
}

output "iam_info" {
  description = "Grouped info for IAM user and policy"
  sensitive = true
  value = {
    user_name   = aws_iam_user.admin-user.name
    user_arn    = aws_iam_user.admin-user.arn
    policy_name = aws_iam_policy.readonly_all.name
    policy_arn  = aws_iam_policy.readonly_all.arn
    password = aws_iam_user_login_profile.admin_user_password.password
  }
}
