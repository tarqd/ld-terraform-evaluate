# Overview

This is a simple example of evaluating LaunchDarkly feature flags within terraform using the external data provider.

# Usage

## Terraform Setup

```
export TF_VAR_ld_client_side_id=<your client side id>
terraform init 
```

## Evaluation

In `main.tf`, you can choose which flags will be returned and their respective fallback values. You should also pass a context. Since the external data provider only allows single-level objects with string values, you must jsonencode the flags and context object:

```hcl
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
        })
    }
}
```

## Using flags

Due to limitations in the external data resource, all values for flags will be strings. You will need to account for this when using flags. Here's an example of conditionally enabling a resource based on a boolean flag

```hcl
resource null_resource dummy {
    count = tobool(data.external.flags.result.enable-terraform-test) ? 1 : 0
    provisioner "local-exec" {
        command = "echo 'Terraform demo is enabled'"
    }
   
}
```

You can also use number flags if you want to control how many of a resource will be created
```hcl
resource null_resource foo {
    count = tonumber(data.external.flags.result.config-number-of-foo)
}
```