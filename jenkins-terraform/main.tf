# Aws Iam role creation
resource "aws_iam_role" "youtube_role" {
  name = "youtube_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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
    tag-key = "youtube-clone"
  }
}

# Creating the policy attachment
resource "aws_iam_role_policy_attachment" "youtube-attach" {
  role       = aws_iam_role.youtube_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Creating the instance profile
resource "aws_iam_instance_profile" "youtube_profile" {
  name = "youtube-terraform"
  role = aws_iam_role.youtube_role.name
}

# Creating Security Grp
resource "aws_security_group" "youtube_sg" {
  name        = "youtube-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  

  ingress = [ 
    for port in [22, 80, 443, 8080, 3000] : {
        description  = "Allow inbound traffic"
        from_port    = port
        to_port      = port
        protocol     = "tcp"
        cidr_blocks   = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups  = []
        self             = false

    }
   ]

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "youtube security grp"
  }
}

# Creating Ec2 instance
resource "aws_instance" "youtube" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.large"
  key_name               = "demo-001"
  vpc_security_group_ids = [aws_security_group.youtube_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.youtube_profile.name

  user_data              = templatefile("./install_jenkins.sh", {})

  tags = {
    Name = "youtube server"
  }

  root_block_device {
    volume_size = 30
  }
}