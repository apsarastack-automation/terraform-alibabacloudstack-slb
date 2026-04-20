run "setup" {
  command = apply
  module {
    source = "./setup_slb/slb_instance"
  }
  variables {
    name = "tf-test-slb-instance"
  }
}

run "validate" {
  command = apply
  module {
    source = "../examples/create-slb-instance"
  }
  variables {
    name          = "tf-test-slb-instance"
    vswitch_id    = run.setup.vswitch_id
    specification = "slb.s1.small"
  }

  assert {
    condition     = output.slb_id != ""
    error_message = "The SLB instance creation failed"
  }

  assert {
    condition     = output.slb_address != ""
    error_message = "The SLB instance should have an IP address"
  }

  assert {
    condition     = output.slb_name == "tf-test-slb-instance"
    error_message = "The SLB name should match the input"
  }
}