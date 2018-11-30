output "vpc" {
  value = "${
    map(
      "vpc_id", "${aws_vpc.vpc.id}",
      "nat_ip_1", "${aws_eip.nat_ip_1.public_ip}",
      "nat_ip_2", "${aws_eip.nat_ip_2.public_ip}",
      "nat_ip_3", "${aws_eip.nat_ip_3.public_ip}"
    )
  }"
}
