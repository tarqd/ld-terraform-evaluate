terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

variable "client_side_id" {
  type = string
  description = "LaunchDarkly Client-Side ID used to evaluate flags in Terraform"
}

variable "flags" {
    type = map(any)
    description = "Flags to evaluate and their fallback values"
}

variable "context" {
    type = map(any)
    description = "Context used for evaluation"
}

variable "poll_uri" {
    type = string
    default = "https://clientsdk.launchdarkly.com"
    description = "URI that will be used to request flags"
}

data http flag_request {
    url = "${var.poll_uri}/sdk/evalx/${var.client_side_id}/contexts/${local.context_b64}"
    method = "GET"
    request_headers = {
      "Content-Type" = "application/json"
    }
   
}

locals {
    response = jsondecode(data.http.flag_request.response_body)
    context_b64 = replace(replace(replace(base64encode(jsonencode(var.context)), "=", ""), "+", "-"), "/", "_")
}

output status_code {
    description = "HTTP Status Code from LaunchDarkly"
    value = data.http.flag_request.status_code
}

output parsed_response {
    description = "JSON Decoded response from LaunchDarkly"
    value = local.response
}


output "flags" {
    description ="Flag evaluation results or fallback values"
    value = {
        for k,v in var.flags: k => try(local.response[k].value, v)
    }
}
