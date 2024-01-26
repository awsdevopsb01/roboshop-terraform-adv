# Terraform 

#Understanding a Block

#Resource Block:
resource "ec2-instance" "instance" {
ami = "ami-03265a0778a880afb"
instance_type = "t3.micro"

tags = {
Name   = "instance"
}
}

resource : This is a Terraform keyword that is used to create resources
ec2-instance : This is the resource type
instance : Name of the resource
ami : Amazon Machine Image
instance_type: Type of the machine/server
tags : Terraform metadata of the block.