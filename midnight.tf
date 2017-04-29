provider "aws" {
  shared_credentials_file = "./aws-credentials"
  region = "us-west-2"
  alias = "oregon"
}

provider "aws" {
  shared_credentials_file = "./aws-credentials"
  region = "sa-east-1"
  alias = "saopaolo"
}

provider "aws" {
  shared_credentials_file = "./aws-credentials"
  region = "ap-northeast-2"
  alias = "seoul"
}

resource "aws_security_group" "allow_global_ssh" {
  provider = "aws.oregon"
  name = "allow_global_ssh"
  description = "allow tcp/22 from everywhere"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "midnight_hub_west" {
  provider = "aws.oregon"
  ami           = "ami-efd0428f"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_global_ssh.id}"]
  tags {
    Name = "midnight_hub_west"
  }
}

resource "aws_eip" "midnight_hub_west" {
  provider = "aws.oregon"
  instance = "${aws_instance.midnight_hub_west.id}"
  vpc      = true
}

resource "aws_security_group" "allow_west_ssh" {
  provider = "aws.saopaolo"
  name = "allow_west_ssh"
  description = "allow tcp/22 from midnight-west"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_eip.midnight_hub_west.public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "midnight-hub-south" {
  provider = "aws.saopaolo"
  ami           = "ami-4090f22c"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_west_ssh.id}"]
  tags {
    Name = "midnight-hub-south"
  }
}

resource "aws_instance" "midnight-hub-core" {
  provider = "aws.seoul"
  ami           = "ami-66e33108"
  instance_type = "t2.micro"
  tags {
    Name = "midnight-hub-core"
  }
}
