variable "region" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "server_count" {}
variable "client_count" {}
variable "retry_join" {}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "hashistack" {
  name   = "hashistack"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nomad
  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Consul
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data_server" {
  template = "${file("${path.root}/user-data-server.sh")}"

  vars {
    server_count = "${var.server_count}"
    region       = "${var.region}"
    retry_join   = "${var.retry_join}"
  }
}

data "template_file" "user_data_client" {
  template = "${file("${path.root}/user-data-client.sh")}"

  vars {
    region     = "${var.region}"
    retry_join = "${var.retry_join}"
  }
}

resource "aws_instance" "server" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.hashistack.id}"]
  count                  = "${var.server_count}"

  #Instance tags
  tags {
    Name           = "hashistack-server-${count.index}"
    ConsulAutoJoin = "auto-join"
  }

  user_data            = "${data.template_file.user_data_server.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
}

resource "aws_instance" "client" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.hashistack.id}"]
  count                  = "${var.client_count}"
  depends_on             = ["aws_instance.server"]

  #Instance tags
  tags {
    Name           = "hashistack-client-${count.index}"
    ConsulAutoJoin = "auto-join"
  }

  user_data            = "${data.template_file.user_data_client.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "hashistack"
  role        = "${aws_iam_role.instance_role.name}"
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "hashistack"
  assume_role_policy = "${data.aws_iam_policy_document.instance_role.json}"
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "auto-discover-cluster"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${data.aws_iam_policy_document.auto_discover_cluster.json}"
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

output "server_public_ips" {
  value = ["${aws_instance.server.*.public_ip}"]
}

output "client_public_ips" {
  value = ["${aws_instance.client.*.public_ip}"]
}
