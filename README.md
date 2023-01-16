# terraform_aws_vpc_module

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Amazon VPC is a virtual network that closely resembles a traditional network that we would operate in our own data center. It provides a logically isolated area of the AWS cloud where we can launch AWS resources in a virtual network we define. We have complete control over our virtual networking environment, including selecting IP address ranges, creating subnets, and configuring route tables and network gateways.

Using this terraform code, we can create a VPC with six subnets: three public and three private, elastic IP and NAT Gateway, internet gateway, route tables, and route table association.

## Features

- This VPC module can be used in multiple terraform projects.
- Elastic IP and NAT gateway are optional. They won't be created if we set the boolean variable enable_nat_gateway = false


| Variable  |Description |
| ------------- | ------------- |
| project  | project name  |
|  environment  | project environment |
|  vpc_cidr  | CIDR block for the new VPC |
|  enable_nat_gateway  | Variable that defines if a NAT gateway is required or not |


