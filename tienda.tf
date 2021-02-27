module "tienda_vpc" {
  source               = "git@github.com:adecchi/terraform-aws-vpc.git?ref=tags/0.0.1"
  name                 = "tienda-vpc"
  cidr                 = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  public_security_group = {
    "ssh-internet" = {
      from_port   = "22",
      to_port     = "22",
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "SSH"
    },
    "http-internet" = {
      from_port   = "80",
      to_port     = "80",
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "HTTP"
    },
  }
}

module "tienda_ec2_apache" {
  source                      = "git@github.com:adecchi/terraform-aws-ec2.git?ref=tags/0.0.1"
  create_key_name             = true
  public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHzJhZ2nVljIC5AAJW3RsrV6rHHKm2Xy2FR7MBlsAIVbNhq3sz+Xk/FAf1+l8k5IQDl0nTNzNYgSAfuA/q2bnVxrOylPtXOHkmcNM8xABrorcCmCJaGJrj9+h3LwOxWVga7919URNmpzmI83SYtMuHf/gUj7+WOZzMikGmukdqzl7iwPJIxGr6KGlRJwt9auFHmfrSm6vc8ZMVHQ0TCcfFEATu5T0IivHe/RI+81eUI6wyEaYIWob0x7jw6/60rOj8pQpU8yEIgdumgO5ODJB+o6yyTy3xV2BdqblBdRqLzRduTwVjivqrABL6YGLmdzK9ncSflJ0BK0iSGWScY9wACGThM4Mf1DZgisz6EZVlW0M8BsDpZryrm5cugpMZDPl+d/2nl5XAVK6slTQbnsX2nhxr4Wo3BZ2YecjM0fplyzdfHpdu0aR8xSAYK1vnlIx+p/zH+D+3Tqn7sjI9gSCScG7ihqGCoz5QZbfHEKSiqim7gPqVMyz6iCPCjbJge9E= alejandro.decchi@2innovateit.com"
  name                        = "tienda-ec2-apache"
  key_name                    = "adecchi"
  amount_instances            = 1
  ami                         = "ami-0915bcb5fa77e4892"
  instance_type               = "t2.micro"
  monitoring                  = true
  vpc_security_group_ids      = [module.tienda_vpc.public_security_group_id]
  subnet_id                   = module.tienda_vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data                   = file("scripts/install_apache.sh")
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  depends_on = [module.tienda_vpc]
}

module "tienda_ec2_nginx" {
  source                      = "git@github.com:adecchi/terraform-aws-ec2.git?ref=tags/0.0.1"
  name                        = "tienda-ec2-nginx"
  key_name                    = "adecchi"
  amount_instances            = 1
  ami                         = "ami-0915bcb5fa77e4892"
  instance_type               = "t2.micro"
  monitoring                  = true
  vpc_security_group_ids      = [module.tienda_vpc.public_security_group_id]
  subnet_id                   = module.tienda_vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data                   = file("scripts/install_nginx.sh")
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  depends_on = [module.tienda_vpc, module.tienda_ec2_apache]
}

module "tienda_alb" {
  source          = "git@github.com:adecchi/terraform-aws-alb.git?ref=tags/0.0.1"
  create_lb       = true
  vpc_id          = module.tienda_vpc.vpc_id
  security_groups = [module.tienda_vpc.public_security_group_id]
  subnets         = module.tienda_vpc.public_subnet_ids
  target_groups = [{
    name             = "WEB-SERVERS"
    backend_protocol = "HTTP"
    backend_port     = 80
    }
  ]
  http_tcp_listeners = [{
    protocol = "HTTP"
    port     = 80
    }
  ]
  instances_ids = concat(module.tienda_ec2_apache.ids, module.tienda_ec2_nginx.ids)
  depends_on    = [module.tienda_ec2_apache, module.tienda_ec2_nginx]
}

output "loabalancer" {
  value      = module.tienda_alb.lb_dns_name
  depends_on = [module.tienda_alb]
}

