###################
#  MIDNIGHT WEST  #
###################

provider "aws" {
  shared_credentials_file = "../credentials/aws-credentials"
  region                  = "us-west-2"
  alias                   = "oregon"
  version                 = "~> 2.66"
}

resource "aws_key_pair" "admin-key-oregon" {
  provider   = aws.oregon
  key_name   = "midnight-admin-key"
  public_key = file("../credentials/access_key.pub")
}

resource "aws_security_group" "midnight-west" {
  provider    = aws.oregon
  name        = "midnight-west"
  description = "midnight west security group (allow 22 from anywhere)"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "midnight-hub-west" {
  provider               = aws.oregon
  ami                    = "ami-003634241a8fcdec0"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.admin-key-oregon.key_name
  vpc_security_group_ids = [aws_security_group.midnight-west.id]
  tags = {
    Name = "midnight-hub-west"
  }
}

resource "aws_eip" "midnight-hub-west" {
  provider = aws.oregon
  instance = aws_instance.midnight-hub-west.id
  vpc      = true
}

####################
#  MIDNIGHT SOUTH  #
####################

provider "aws" {
  shared_credentials_file = "../credentials/aws-credentials"
  region                  = "sa-east-1"
  alias                   = "saopaolo"
  version                 = "~> 2.66"
}

resource "aws_key_pair" "admin-key-saopaolo" {
  provider   = aws.saopaolo
  key_name   = "midnight-admin-key"
  public_key = file("../credentials/access_key.pub")
}

resource "aws_security_group" "midnight-south" {
  provider    = aws.saopaolo
  name        = "midnight-south"
  description = "allow tcp/23 from midnight-west and ssh from controller"

  ingress {
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.midnight-hub-west.public_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(file("../credentials/controller_ip"))}/32"]
  }

  # Also allow ping so that nmap doesn't require -Pn
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${aws_eip.midnight-hub-west.public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "midnight-hub-south" {
  provider               = aws.saopaolo
  ami                    = "ami-077d5d3682940b34a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.admin-key-saopaolo.key_name
  vpc_security_group_ids = [aws_security_group.midnight-south.id]
  tags = {
    Name = "midnight-hub-south"
  }
}

resource "aws_eip" "midnight-hub-south" {
  provider = aws.saopaolo
  instance = aws_instance.midnight-hub-south.id
  vpc      = true
}

###################
#  MIDNIGHT CORE  #
###################

provider "aws" {
  shared_credentials_file = "../credentials/aws-credentials"
  region                  = "ap-northeast-2"
  alias                   = "seoul"
  version                 = "~> 2.66"
}

resource "aws_key_pair" "admin-key-seoul" {
  provider   = aws.seoul
  key_name   = "midnight-admin-key"
  public_key = file("../credentials/access_key.pub")
}

resource "aws_security_group" "midnight-core" {
  provider    = aws.seoul
  name        = "midnight-core"
  description = "allow all traffic from the midnight south hub"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_eip.midnight-hub-south.public_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(file("../credentials/controller_ip"))}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "midnight-hub-core" {
  provider               = aws.seoul
  ami                    = "ami-00edfb46b107f643c"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.admin-key-seoul.key_name
  vpc_security_group_ids = [aws_security_group.midnight-core.id]
  tags = {
    Name = "midnight-hub-core"
  }
}

resource "aws_eip" "midnight-hub-core" {
  provider = aws.seoul
  instance = aws_instance.midnight-hub-core.id
  vpc      = true
}

output "midnight-hub-west-ip" {
  value = aws_eip.midnight-hub-west.public_ip
  description = "midnight-hub-west IP address"
}

output "midnight-hub-south-ip" {
  value = aws_eip.midnight-hub-south.public_ip
  description = "midnight-hub-south IP address"
}

output "midnight-hub-core-ip" {
  value = aws_eip.midnight-hub-core.public_ip
  description = "midnight-hub-core IP address"
}
