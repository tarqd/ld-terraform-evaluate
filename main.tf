variable "ld_client_side_id" {
  description = "LaunchDarkly client side ID used to evaluate flags in terraform"
  type = string
}
data "external" "git-branch" {
    program = ["${path.module}/scripts/git-info.sh"]
}

# External data provider only accepts and returns values as strings
data "external" "flags" {
    program = ["${path.module}/scripts/ld-evalulate.sh"]
    query = {
        client_side_id = var.ld_client_side_id
        flags = jsonencode({
            "enable-terraform-test": false
        })
        context = jsonencode({
            "kind": "terraform"
            "name": "${path.root}",
            "key": "${sha1(format("%s-%s", path.root, terraform.workspace))}",
            "module": "${path.module}",
            "workspace": "${terraform.workspace}",
            "branch": "${data.external.git-branch.result.branch}",
            "commit": "${data.external.git-branch.result.commit}"
        })
    }
}

resource null_resource dummy {
    count = tobool(data.external.flags.result.enable-terraform-test) ? 1 : 0
    provisioner "local-exec" {
        command = "echo 'Terraform demo is enabled'"
    }
}
