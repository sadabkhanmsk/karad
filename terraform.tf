variable "cird_innov" {
    default = "10.0.0.0/16"
  
}

resource "aws_key_pair" "innov_key" {
    key_name = "innov"
    public_key = file("C:/Users/sadab/Downloads/sadabtf/id_rsa.pub")
  
}

resource "aws_vpc" "innov_vpc" {
    cidr_block = var.cird_innov
  
}

resource "aws_subnet" "innov_subnet" {
    vpc_id = aws_vpc.innov_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-northeast-3a"
    map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "innov_internet" {
    vpc_id = aws_vpc.innov_vpc.id
  
}

resource "aws_route_table" "innov_route_table" {
    vpc_id = aws_vpc.innov_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.innov_internet.id
    }
}

resource "aws_route_table_association" "innov_asso" {
    route_table_id = aws_route_table.innov_route_table.id
    subnet_id = aws_subnet.innov_subnet.id
  
}

resource "aws_security_group" "innov_security" {
    name = "sadab"
    vpc_id = aws_vpc.innov_vpc.id

    ingress {
        description = "allow port for http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "allow port for ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    tags = {
      Name = "sadab"
    }
  
}


resource "aws_instance" "innov_instance" {
    ami = "ami-05f4d8898209c4f55"
    instance_type = "t2.micro"
    key_name = aws_key_pair.innov_key.key_name
    vpc_security_group_ids = [aws_security_group.innov_security.id]
    subnet_id = aws_subnet.innov_subnet.id

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("C:/Users/sadab/Downloads/sadabtf/id_rsa")
      host = self.public_ip
    }

    provisioner "file" {
        source = "index.html"
        destination = "/home/ubuntu/index.html"
      
    }

    provisioner "remote-exec" {
        inline = [  
            "sudo apt update -y",
            "sudo apt install nginx -y",
            "cp /home/ubuntu/index.html /var/www/html/index.html"
        ]
      
    }
  
}

output "public_ipaddress" {
    value = aws_instance.innov_instance.public_ip
  
}