variable "ld_client_side_id" {
  description = "LaunchDarkly client side ID used to evaluate flags in terraform"
  type = string
}


module "ld" {
    source = "./ld-evaluate"
    client_side_id = var.ld_client_side_id
    flags = {
        "enable-terraform-test" = true
    }
    context = {
            "kind": "terraform"
            "name": "${path.root}",
            "key": "${sha1(format("%s-%s", path.root, terraform.workspace))}",
            "module": "${path.module}",
            "workspace": "${terraform.workspace}",
        }
}

resource null_resource dummy {
    count = module.ld.flags.enable-terraform-test ? 1 : 0
    provisioner "local-exec" {
        command = "echo 'Terraform demo is enabled'"
    }
}
