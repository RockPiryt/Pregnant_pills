
#To jest tzw. trust policy.(Zezwól usłudze EC2 na przejęcie (AssumeRole) tej roli.) Bez tego rola by istniała, ale EC2 nie mogłoby jej użyć.
 # Z jakich rol moze korzytac e2
# Trust policy to allow EC2 to use role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # tylko ec2 moze korzystac z tej roli
    }
  }
}
# Create ssm role for ec2
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "preg-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
 
# Add policy to ssm_role
# Dodanie konkretnych uprawnien
#Ta polityka pozwala instancji:zarejestrować się w Systems Manager,otworzyć Session Manager, komunikować się z usługą SSM, Czyli to jest dokładnie to, co daje Ci „zdalny shell bez SSH”.
resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Bo EC2 nie przypina się bezpośrednio do roli IAM.
# profile to jakby opakowanie na role IAM
# Add role to Instance Profile
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "preg-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}