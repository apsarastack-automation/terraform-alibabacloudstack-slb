run "validate" {
  command = apply
  module {
    source = "../"
  }
  variables {
    name          = "tf-test-slb"
    address_type  = "intranet"
    specification = "slb.s1.small"
    listeners = [
      {
        frontend_port = 80
        backend_port  = 8080
        protocol      = "http"
        bandwidth     = 10
        scheduler     = "wrr"
      }
    ]
  }

  assert {
    condition     = output.slb_id != ""
    error_message = "SLB ID should not be empty."
  }

  assert {
    condition     = output.slb_name == "tf-test-slb"
    error_message = "SLB name should match input."
  }

  assert {
    condition     = output.address != ""
    error_message = "SLB address should not be empty."
  }

  assert {
    condition     = length(output.listener_ids) > 0
    error_message = "At least one listener should be created."
  }
}