variables {
  enable_provisioner = false
}

run "ec2_test" {

  command = apply

  assert {
    condition     = module.ec2_instance.instance_id != ""
    error_message = "EC2 instance should be created"
  }

}
