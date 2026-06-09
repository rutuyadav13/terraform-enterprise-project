module "vpc" {

  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"

  private_subnet_1_cidr = "10.0.3.0/24"
  private_subnet_2_cidr = "10.0.4.0/24"

  availability_zone_1 = "ap-south-1a"
  availability_zone_2 = "ap-south-1b"
}

module "security_group" {

  source = "./modules/security-group"

  vpc_id = module.vpc.vpc_id

  my_ip = "42.107.66.32/32"
}

module "ec2" {

  source = "./modules/ec2"

  instance_type = "t3.micro"

  private_subnet_id = module.vpc.private_subnet_ids[0]

  ec2_sg_id = module.security_group.ec2_sg_id
}

module "alb" {

  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  alb_sg_id = module.security_group.alb_sg_id

}


module "launch_template" {

  source = "./modules/launch-template"

  instance_type = "t3.micro"

  ec2_sg_id = module.security_group.ec2_sg_id
}

module "asg" {

  source = "./modules/asg"

  launch_template_id = module.launch_template.launch_template_id

  private_subnet_ids = module.vpc.private_subnet_ids

  target_group_arn = module.alb.target_group_arn
}

module "cloudwatch" {

  source = "./modules/cloudwatch"

  asg_name = module.asg.asg_name
}