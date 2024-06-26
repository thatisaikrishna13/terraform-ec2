variable "ami_id" {
  description = "AMI ID for the Jenkins instance"
  default     = "ami-0807eb45a1bda42b1"
}

variable "instance_type" {
  description = "Instance type for the Jenkins instance"
  default     = "t2.medium"
}

resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security-Group"
  description = "Security group for Jenkins server, allowing SSH, HTTP, HTTPS, Jenkins, and SonarQube ports"

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "Allow TCP traffic on port ${port} from anywhere"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "saithati"
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  user_data              = file("./install_jenkins.sh")

  tags = {
    Name = "Jenkins-sonar"
  }

  root_block_device {
    volume_size = 30
  }
}

