variable "ld_client_side_id" {
  description = "LaunchDarkly client side ID used to evaluate flags in terraform"
  type = string
}
data "external" "git-branch" {
    program = ["${path.module}/scripts/git-info.sh"]
}

# External data provider only returns values as strings
# so if a flag is a boolean you  need to check if it's "true" or "false"
data "external" "flags" {
    program = ["${path.module}/scripts/ld-evalulate.sh"]
    query = {
        client_side_id = "62ea8c4afac9b011945f6791"
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
    count = data.external.flags.result.enable-terraform-test == "true" ? 1 : 0
    provisioner "local-exec" {
        command = "echo 'Terraform demo is enabled'"
    }
   
}
