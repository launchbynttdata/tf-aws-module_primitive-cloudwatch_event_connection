# Terraform AWS Module: EventBridge Connection

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

This module manages an [AWS EventBridge (CloudWatch Events) connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) for authenticating to external HTTP endpoints used by API destinations. Connections store credentials in AWS Secrets Manager and support API key, Basic, and OAuth client credentials authentication.

## Pre-Commit Hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines pre-commit hooks for Terraform, Golang, and common linting. The `commitlint` hook enforces conventional commit format. The `detect-secrets-hook` prevents new secrets from being introduced into the baseline.

To install hooks:

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

## Usage

```hcl
module "event_connection" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/cloudwatch_event_connection/aws"
  version = "~> 1.0"

  name               = "my-api-connection"
  authorization_type = "API_KEY"
  auth_parameters = {
    api_key = {
      key   = "x-api-key"
      value = "secret-value"
    }
  }
  description        = "Connection for API destination"
  kms_key_identifier = aws_kms_key.connection.arn
}
```

## Testing

1. Run `make configure` to install dependencies.
2. For AWS: set up credentials (e.g., `AWS_PROFILE`, `AWS_ACCESS_KEY_ID`).
3. Run `make check` to run lint, validate, plan, and Terratest.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_connection.connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the connection. Must be unique within the region. Length 1-64. Pattern: ^[0-9A-Za-z\_.-]+ | `string` | n/a | yes |
| <a name="input_authorization_type"></a> [authorization\_type](#input\_authorization\_type) | Type of authorization to use. One of: API\_KEY, BASIC, OAUTH\_CLIENT\_CREDENTIALS | `string` | n/a | yes |
| <a name="input_auth_parameters"></a> [auth\_parameters](#input\_auth\_parameters) | Authentication parameters. Exactly one of api\_key, basic, or oauth must be set based on authorization\_type.<br/>- api\_key: For API\_KEY - key and value<br/>- basic: For BASIC - username and password<br/>- oauth: For OAUTH\_CLIENT\_CREDENTIALS - authorization\_endpoint, http\_method, client\_parameters, oauth\_http\_parameters<br/>- invocation\_http\_parameters: Optional - body, header, query\_string params for each invocation | <pre>object({<br/>    api_key = optional(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>    basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>    oauth = optional(object({<br/>      authorization_endpoint = string<br/>      http_method            = string<br/>      client_parameters = optional(object({<br/>        client_id     = string<br/>        client_secret = string<br/>      }))<br/>      oauth_http_parameters = object({<br/>        body = optional(list(object({<br/>          key             = optional(string)<br/>          value           = optional(string)<br/>          is_value_secret = optional(bool, false)<br/>        })), [])<br/>        header = optional(list(object({<br/>          key             = optional(string)<br/>          value           = optional(string)<br/>          is_value_secret = optional(bool, false)<br/>        })), [])<br/>        query_string = optional(list(object({<br/>          key             = optional(string)<br/>          value           = optional(string)<br/>          is_value_secret = optional(bool, false)<br/>        })), [])<br/>      })<br/>    }))<br/>    invocation_http_parameters = optional(object({<br/>      body = optional(list(object({<br/>        key             = optional(string)<br/>        value           = optional(string)<br/>        is_value_secret = optional(bool, false)<br/>      })), [])<br/>      header = optional(list(object({<br/>        key             = optional(string)<br/>        value           = optional(string)<br/>        is_value_secret = optional(bool, false)<br/>      })), [])<br/>      query_string = optional(list(object({<br/>        key             = optional(string)<br/>        value           = optional(string)<br/>        is_value_secret = optional(bool, false)<br/>      })), [])<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the connection. Length 0-512. | `string` | `null` | no |
| <a name="input_invocation_connectivity_parameters"></a> [invocation\_connectivity\_parameters](#input\_invocation\_connectivity\_parameters) | Connectivity parameters for invocation (e.g., VPC Lattice). Used for private API access. | <pre>object({<br/>    resource_parameters = object({<br/>      resource_configuration_arn = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_kms_key_identifier"></a> [kms\_key\_identifier](#input\_kms\_key\_identifier) | ARN of the KMS key used to encrypt the connection credentials in Secrets Manager. Omit for AWS-managed encryption. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the connection (same as the name). |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the connection. |
| <a name="output_name"></a> [name](#output\_name) | The name of the connection. |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | The ARN of the secret in Secrets Manager where connection credentials are stored. |
<!-- END_TF_DOCS -->
