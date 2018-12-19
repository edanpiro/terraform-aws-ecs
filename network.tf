resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "pse vpc"
  }
}

resource "aws_subnet" "backend" {
  count             = "${length(var.subnet_public_cidr)}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(var.subnet_public_cidr, count.index)}"
  availability_zone = "${element(var.subnet_public_zone, count.index)}"
  map_public_ip_on_launch = true
  
  tags {
    Name = "pse public subnet backend1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "pse internet gateway"
  }
}

resource "aws_eip" "ip_nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_ip" {
  allocation_id = "${aws_eip.ip_nat.id}"
  subnet_id     = "${element(aws_subnet.backend.*.id, 0)}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "route_public" {
  vpc_id = "${aws_vpc.default.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "pse Public subnet"
  }
}

resource "aws_route_table_association" "route_public" {
  count          = "${length(var.subnet_public_zone)}"
  subnet_id      = "${element(aws_subnet.backend.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_public.id}"
}

resource "aws_route_table" "route_private" {
  vpc_id = "${aws_vpc.default.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_ip.id}"
  }

  tags {
    Name = "pse Public subnet"
  }
}
