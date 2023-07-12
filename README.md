# Overview

This is a simple example of evaluating LaunchDarkly feature flags within terraform using the hashicorp/http provider.

# Usage

Since this uses the client-side evaluation endpoint, you will need to ensure that the flags are available for client-side SDKs. Check the client-side availability settings if you're getting fallback values unexpectedly. Alternatively, you can deploy LD Relay, open `ld-evaluate/main.tf` and replace the url with `http://my-relay-host/sdk/evalx/context`. You will need to pass an SDK key via the Authorization header, send the context as a response_body and change the method to POST/REPORT

## Terraform Setup

```
export TF_VAR_ld_client_side_id=<your client side id>
terraform init 
```

## Evaluation

In `main.tf`, you can choose which flags will be returned and their respective fallback values. You should also pass a context. Evaluation is provided by the `./ld-evaluate` module which uses [hashicorp/http](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) to request flags from LaunchDarkly.

```hcl
data "external" "flags" {
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
```

## Using flags

Evaluated flags will be returned in the `flags` output of the module

```hcl
resource null_resource dummy {
    count = module.ld.flags.enable-terraform-test ? 1 : 0
    provisioner "local-exec" {
        command = "echo 'Terraform demo is enabled'"
    }
}
```

You can also use number flags if you want to control how many of a resource will be created
```hcl
resource null_resource dummy {
    count = module.ld.flags.config-dummy-count
    provisioner "local-exec" {
        command = "echo 'Terraform demo is enabled'"
    }
}
```
