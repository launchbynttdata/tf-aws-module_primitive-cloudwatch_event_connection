# EventBridge Connection - Complete Example

This example creates an EventBridge connection with API key authentication, using a customer-managed KMS key for encrypting credentials in Secrets Manager (security-first).

## Usage

```hcl
data "aws_region" "current" {}

module "resource_names" {
  source   = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version  = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region = join("", split("-", data.aws_region.current.name))
}

resource "aws_kms_key" "connection" {
  description             = "KMS key for EventBridge connection ${module.resource_names["event_connection"].standard}"
  deletion_window_in_days  = var.kms_deletion_window_in_days
  enable_key_rotation      = var.kms_enable_key_rotation
  tags                     = var.tags
}

resource "aws_kms_alias" "connection" {
  name          = "alias/${module.resource_names["kms_key"].standard}"
  target_key_id = aws_kms_key.connection.key_id
}

module "event_connection" {
  source = "../.."

  name               = module.resource_names["event_connection"].standard
  authorization_type = var.authorization_type
  auth_parameters    = var.auth_parameters
  description        = var.description
  kms_key_identifier = aws_kms_key.connection.arn
  invocation_connectivity_parameters = var.invocation_connectivity_parameters
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource_names_map](#input\_resource_names_map) | Map of key to resource_name config for the resource_name module. | `map(object({ name = string, max_length = number }))` | n/a | yes |
| <a name="input_logical_product_family"></a> [logical_product_family](#input\_logical_product_family) | Logical product family for resource naming. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical_product_service](#input\_logical_product_service) | Logical product service for resource naming. | `string` | n/a | yes |
| <a name="input_class_env"></a> [class_env](#input\_class_env) | Class environment for resource naming (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_instance_env"></a> [instance_env](#input\_instance_env) | Instance environment index for resource naming. | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance_resource](#input\_instance_resource) | Instance resource index for resource naming. | `number` | n/a | yes |
| <a name="input_authorization_type"></a> [authorization_type](#input\_authorization_type) | Type of authorization. One of: API_KEY, BASIC, OAUTH_CLIENT_CREDENTIALS | `string` | n/a | yes |
| <a name="input_auth_parameters"></a> [auth_parameters](#input\_auth_parameters) | Authentication parameters. Exactly one of api_key, basic, or oauth must be set. | `object` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the connection. | `string` | `null` | no |
| <a name="input_invocation_connectivity_parameters"></a> [invocation_connectivity_parameters](#input\_invocation_connectivity_parameters) | Connectivity parameters for invocation (e.g., VPC Lattice). | `object` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources. | `map(string)` | `{}` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms_deletion_window_in_days](#input\_kms_deletion_window_in_days) | Number of days before KMS key is deleted. | `number` | `7` | no |
| <a name="input_kms_enable_key_rotation"></a> [kms_enable_key_rotation](#input\_kms_enable_key_rotation) | Whether to enable automatic key rotation for the KMS key. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the connection. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the connection. |
| <a name="output_name"></a> [name](#output\_name) | The name of the connection. |
| <a name="output_secret_arn"></a> [secret_arn](#output\_secret_arn) | The ARN of the secret in Secrets Manager. |
| <a name="output_kms_key_arn"></a> [kms_key_arn](#output\_kms_key_arn) | The ARN of the KMS key used to encrypt the connection credentials. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.14 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_connection"></a> [event\_connection](#module\_event\_connection) | ../.. | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_parameters"></a> [auth\_parameters](#input\_auth\_parameters) | Authentication parameters. Exactly one of api\_key, basic, or oauth must be set. | <pre>object({<br/>    api_key = optional(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>    basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>    oauth = optional(object({<br/>      authorization_endpoint = string<br/>      http_method            = string<br/>      client_parameters = optional(object({<br/>        client_id     = string<br/>        client_secret = string<br/>      }))<br/>      oauth_http_parameters = object({<br/>        body = optional(list(object({<br/>          key             = optional(string)<br/>          value           = optional(string)<br/>          is_value_secret = optional(bool, false)<br/>        })), [])<br/>        header = optional(list(object({<br/>          key             = optional(string)<br/>          value           = optional(string)<br/>          is_value_secret = optional(bool, false)<br/>        })), [])<br/>        query_string = optional(list(object({<br/>          key             = optional(string)<br/>          value           = optional(string)<br/>          is_value_secret = optional(bool, false)<br/>        })), [])<br/>      })<br/>    }))<br/>    invocation_http_parameters = optional(object({<br/>      body = optional(list(object({<br/>        key             = optional(string)<br/>        value           = optional(string)<br/>        is_value_secret = optional(bool, false)<br/>      })), [])<br/>      header = optional(list(object({<br/>        key             = optional(string)<br/>        value           = optional(string)<br/>        is_value_secret = optional(bool, false)<br/>      })), [])<br/>      query_string = optional(list(object({<br/>        key             = optional(string)<br/>        value           = optional(string)<br/>        is_value_secret = optional(bool, false)<br/>      })), [])<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_authorization_type"></a> [authorization\_type](#input\_authorization\_type) | Type of authorization. One of: API\_KEY, BASIC, OAUTH\_CLIENT\_CREDENTIALS | `string` | n/a | yes |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Class environment for resource naming (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the connection. | `string` | `null` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Instance environment index for resource naming. | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Instance resource index for resource naming. | `number` | n/a | yes |
| <a name="input_invocation_connectivity_parameters"></a> [invocation\_connectivity\_parameters](#input\_invocation\_connectivity\_parameters) | Connectivity parameters for invocation (e.g., VPC Lattice). | <pre>object({<br/>    resource_parameters = object({<br/>      resource_configuration_arn = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Number of days before KMS key is deleted. | `number` | `7` | no |
| <a name="input_kms_enable_key_rotation"></a> [kms\_enable\_key\_rotation](#input\_kms\_enable\_key\_rotation) | Whether to enable automatic key rotation for the KMS key. | `bool` | `true` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for resource naming. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for resource naming. | `string` | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of key to resource\_name config for the resource\_name module. Each value's name (cloud\_resource\_type) must be alphanumeric only (no underscores), e.g. eventconnection01, kmskey01. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the connection. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the connection. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the connection credentials. |
| <a name="output_name"></a> [name](#output\_name) | The name of the connection. |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | The ARN of the secret in Secrets Manager. |
<!-- END_TF_DOCS -->
