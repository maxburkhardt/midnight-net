###################
#  MIDNIGHT WEST  #
###################

provider "aws" {
  shared_credentials_file = "./aws-credentials"
  region                  = "us-west-2"
  alias                   = "oregon"
}

resource "aws_key_pair" "admin-key-oregon" {
  provider   = "aws.oregon"
  key_name   = "midnight-admin-key"
  public_key = "${file("./access_key.pub")}"
}

resource "aws_security_group" "allow-global-ssh" {
  provider    = "aws.oregon"
  name        = "allow-global-ssh"
  description = "allow tcp/22 from everywhere"

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
  provider               = "aws.oregon"
  ami                    = "ami-efd0428f"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.admin-key-oregon.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow-global-ssh.id}"]
  tags {
    Name = "midnight-hub-west"
  }
}

resource "aws_eip" "midnight-hub-west" {
  provider = "aws.oregon"
  instance = "${aws_instance.midnight-hub-west.id}"
  vpc      = true
}

####################
#  MIDNIGHT SOUTH  #
####################

provider "aws" {
  shared_credentials_file = "./aws-credentials"
  region                  = "sa-east-1"
  alias                   = "saopaolo"
}

resource "aws_key_pair" "admin-key-saopaolo" {
  provider   = "aws.saopaolo"
  key_name   = "midnight-admin-key"
  public_key = "${file("./access_key.pub")}"
}

resource "aws_security_group" "allow-west-telnet" {
  provider    = "aws.saopaolo"
  name        = "allow-west-telnet"
  description = "allow tcp/23 from midnight-west"

  ingress {
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.midnight-hub-west.public_ip}/32"]
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
  provider               = "aws.saopaolo"
  ami                    = "ami-4090f22c"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.admin-key-saopaolo.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow-west-telnet.id}"]
  tags {
    Name = "midnight-hub-south"
  }
}

resource "aws_eip" "midnight-hub-south" {
  provider = "aws.saopaolo"
  instance = "${aws_instance.midnight-hub-south.id}"
  vpc      = true
}

###################
#  MIDNIGHT CORE  #
###################

provider "aws" {
  shared_credentials_file = "./aws-credentials"
  region                  = "ap-northeast-2"
  alias                   = "seoul"
}

resource "aws_key_pair" "admin-key-seoul" {
  provider   = "aws.seoul"
  key_name   = "midnight-admin-key"
  public_key = "${file("./access_key.pub")}"
}

resource "aws_security_group" "allow-south-all" {
  provider    = "aws.seoul"
  name        = "allow-south-all"
  description = "allow all traffic from the midnight south hub"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_eip.midnight-hub-south.public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "midnight-hub-core" {
  provider               = "aws.seoul"
  ami                    = "ami-66e33108"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.admin-key-seoul.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow-south-all.id}"]
  tags {
    Name = "midnight-hub-core"
  }
}

resource "aws_eip" "midnight-hub-core" {
  provider = "aws.seoul"
  instance = "${aws_instance.midnight-hub-core.id}"
  vpc      = true
}
