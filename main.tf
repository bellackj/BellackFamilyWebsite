#################
# Load Balancer #
#################
resource "aws_security_group" "lb_sg" {
  name        = join("-", [local.app_name, "lb-sg"])
  description = "Allow TLS inbound to ALB"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  vpc_id = aws_vpc.bellack_family.id

  tags = merge(local.default_tags, {
    Name   = join("-", [local.app_name, "lb-sg"])
    Region = local.region
  })
}

resource "aws_lb" "bellack" {
  name               = join("-", [local.app_name, "alb"])
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false

  tags = merge(local.default_tags, {
    Name   = join("-", [local.app_name, "alb"])
    Region = local.region
  })
}

##############
# Web Server #
##############
resource "aws_s3_object" "web_server_files" {
  bucket = aws_s3_bucket.bf_web_server_files.id
  key    = "bellackfamily_php_files"
  source = "files/php_files"
}