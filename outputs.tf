output "public_ip" {
  value = "${aws_instance.chainlink.public_ip}"
}