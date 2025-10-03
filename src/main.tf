terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
# 1. VPC (The isolated network)
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "secure-iac-vpc" }
}

# 2. Public Subnets (For the ALB)
resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true # Allows internet access
  tags = { Name = "public-a" }
}

# 3. Private Subnets (For the RDS Database - NO internet access)
resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "${var.region}a"
  tags = { Name = "private-a" }
}
# (Repeat for another AZ, e.g., private_b, to ensure multi-AZ resilience)

# 4. Internet Gateway (For public subnet traffic)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}
# 1. Security Group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound HTTPS only"

  # INGRESS RULE: Allow HTTPS (443) from the entire Internet (0.0.0.0/0)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EGRESS RULE: Allow all outbound traffic (default, but explicitly defined)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group for the RDS Database
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow Postgres traffic from ALB ONLY (Least Privilege)"

  # INGRESS RULE: Allow Postgres (5432) from the ALB's Security Group ID
  ingress {
    from_port       = 5432 # Standard Postgres port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Source is the ALB SG, NOT 0.0.0.0/0
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id] # Use your private subnets
}
resource "aws_db_instance" "app_db" {
  identifier              = "app-database"
  instance_class          = "db.t3.micro"
  engine                  = "postgres"
  engine_version          = "14.7"

  # SECURITY CONTROL 1 (Network): Place in private network
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  # SECURITY CONTROL 2 (Encryption): *** INTENTIONALLY INSECURE FOR FIRST SCAN ***
  # Change this to 'false' for the first Checkov scan:
  storage_encrypted       = true    # CHANGED TO TRUE!

  # Credentials (using variables for security)
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  skip_final_snapshot     = true
}