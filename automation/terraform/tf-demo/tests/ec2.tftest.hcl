run "ec2_test" {

  command = plan

  assert {
    condition     = module.ec2_instance.instance_id != ""
    error_message = "EC2 instance should be created"
  }

}
