    access_key = "${var.aws_access_key}"
provider "aws" {
    secret_key = "${var.secret_key}"
    region = "${var.region}"

}


resource "aws_instance" "server_demo1" {
   ami             = ""
   instance_type   = "t2.micro"
   key_name = "AWS EC2 APR 2018"
   tags{
       Name = "server_demo1"
       Project = "AWS1"
   }
}

resource "aws_eip" "ip_address" {
    instance = "${aws_instance.server_demo1.id}"
}