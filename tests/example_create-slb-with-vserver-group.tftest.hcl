run "setup_network" {
  command = apply
  module {
    source = "./setup_slb/slb_instance"
  }
  variables {
    name = "tf-test-slb-vserver"
  }
}

run "setup_ecs" {
  command = apply
  module {
    source = "./setup_slb/ecs_instances"
  }
  variables {
    name           = "tf-test-slb-vserver"
    vpc_id         = run.setup_network.vpc_id
    vswitch_id     = run.setup_network.vswitch_id
    zone_id        = run.setup_network.zone_id
    instance_count = 2
  }
}

run "validate" {
  command = apply
  module {
    source = "../examples/create-slb-with-vserver-group"
  }
  variables {
    name           = "tf-test-slb-vserver"
    vswitch_id     = run.setup_network.vswitch_id
    specification  = "slb.s2.small"
    backend_servers = [
      {
        server_ids = run.setup_ecs.instance_ids
        port       = 80
        weight     = 100
        type       = "ecs"
      }
    ]
  }

  assert {
    condition     = output.slb_id != ""
    error_message = "The SLB instance creation failed"
  }

  assert {
    condition     = output.vserver_group_id != ""
    error_message = "The VServer group should be created"
  }

  assert {
    condition     = output.listener_id != ""
    error_message = "The listener should be created"
  }
}