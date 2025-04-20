resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = merge(var.tags, {
    Name = "main-vpc"
  })
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(var.tags, {
    Name = "main-subnet"
  })
}

resource "aws_security_group" "redshift" {
  name        = "redshift-security-group"
  description = "Security group for Redshift Serverless"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 5439
    to_port         = 5439
    protocol        = "tcp"
    security_groups = [var.glue_security_group_id]
    description     = "Allow Redshift access from Glue"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow outbound traffic within VPC"
  }

  tags = merge(var.tags, {
    Name = "redshift-sg"
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "vpc-flow-log"
  })
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name              = "/aws/vpc/flow-log"
  retention_in_days = 30
  
  tags = merge(var.tags, {
    Name = "vpc-flow-log-group"
  })
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "172.16.0.0/16"  # Red on-premise
    gateway_id = aws_vpn_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "main-route-table"
  })
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.vpc.id
  
  tags = merge(var.tags, {
    Name = "main-vpn-gateway"
  })
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(var.tags, {
    Name = "main-customer-gateway"
  })
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main.id
  type               = "ipsec.1"
  static_routes_only = true

  tags = merge(var.tags, {
    Name = "main-vpn-connection"
  })
}

resource "aws_vpn_connection_route" "db1" {
  destination_cidr_block = "172.16.1.0/24"  # Subnet de DB1
  vpn_connection_id      = aws_vpn_connection.main.id
}

resource "aws_vpn_connection_route" "db2" {
  destination_cidr_block = "172.16.2.0/24"  # Subnet de DB2
  vpn_connection_id      = aws_vpn_connection.main.id
} 