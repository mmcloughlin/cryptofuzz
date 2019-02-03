resource "aws_spot_fleet_request" "workers" {
	count                               = "${length(var.targets)}"
	iam_fleet_role                      = "${aws_iam_role.fleet_role.arn}"
	replace_unhealthy_instances         = true
	wait_for_fulfillment                = true
	target_capacity                     = "${var.workers_target_ecu}"
	allocation_strategy                 = "lowestPrice"
	fleet_type                          = "maintain"
	terminate_instances_with_expiration = true
  

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "m4.large"
	  weighted_capacity = 6
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "c5.large"
	  weighted_capacity = 9
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "c5.xlarge"
	  weighted_capacity = 17
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "m4.xlarge"
	  weighted_capacity = 13
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "c4.large"
	  weighted_capacity = 8
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "m5.xlarge"
	  weighted_capacity = 16
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "c4.xlarge"
	  weighted_capacity = 16
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "m5.large"
	  weighted_capacity = 8
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "c5d.large"
	  weighted_capacity = 9
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "m5d.large"
	  weighted_capacity = 8
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "c5d.xlarge"
	  weighted_capacity = 17
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}

	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "m5d.xlarge"
	  weighted_capacity = 16
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}


	depends_on = ["aws_iam_role_policy_attachment.fleet-tagging-role-policy-attachment"]
}
