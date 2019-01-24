data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_region" "current" {}

data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.sh")}"

  vars {
    region      = "${data.aws_region.current.name}"
    host_role   = "${aws_iam_role.chainlink.arn}"
    login_email = "${var.login_email}"
    log_group   = "${aws_cloudwatch_log_group.chainlink.name}"
    image_tag   = "${var.image_tag}"
    env_vars    = "${data.template_file.env_var_file.rendered}"
  }
}

data "template_file" "policy" {
  template = "${file("${path.module}/templates/policy.json")}"
}

data "template_file" "role" {
  template = "${file("${path.module}/templates/role.json")}"
}

data "template_file" "env_var_file" {
  template = "${file("${path.module}/templates/config.env")}"

  vars {
    env_vars = "${join("\n", data.template_file.env_vars.*.rendered)}"
  }
}

data "template_file" "env_vars" {
  count = "${length(var.env_vars)}"

  template = "${element(var.env_vars[count.index], 0)}=${element(var.env_vars[count.index], 1)}"
}

resource "aws_iam_role" "chainlink" {
  name               = "chainlink-${var.name}"
  assume_role_policy = "${data.template_file.role.rendered}"
}

resource "aws_iam_role_policy" "chainlink" {
  name   = "chainlink-${var.name}"
  role   = "${aws_iam_role.chainlink.id}"
  policy = "${data.template_file.policy.rendered}"
}

resource "aws_iam_instance_profile" "chainlink" {
  name = "chainlink-${var.name}"
  role = "${aws_iam_role.chainlink.id}"
}

resource "aws_security_group" "chainlink" {
  name   = "chainlink-${var.name}"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.allowed_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "latest_amzn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2018.03*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "chainlink" {
  ami                    = "${data.aws_ami.latest_amzn.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "chainlink-${var.name}"
  subnet_id              = "${element(data.aws_subnet_ids.default.ids, 0)}"
  iam_instance_profile   = "${aws_iam_instance_profile.chainlink.id}"
  vpc_security_group_ids = ["${aws_security_group.chainlink.id}"]
  user_data              = "${data.template_file.userdata.rendered}"

  tags {
    Name = "chainlink-${var.name}"
  }

  depends_on = ["aws_cloudwatch_log_group.chainlink"]
}

resource "aws_cloudwatch_log_group" "chainlink" {
  name = "chainlink-${var.name}"

  retention_in_days = "${var.log_retention}"
}
