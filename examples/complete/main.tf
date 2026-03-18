// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "aws_region" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

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
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  tags                    = var.tags
}

resource "aws_kms_alias" "connection" {
  name          = "alias/${module.resource_names["kms_key"].standard}"
  target_key_id = aws_kms_key.connection.key_id
}

module "event_connection" {
  source = "../.."

  name                               = module.resource_names["event_connection"].standard
  authorization_type                 = var.authorization_type
  auth_parameters                    = var.auth_parameters
  description                        = var.description
  kms_key_identifier                 = aws_kms_key.connection.arn
  invocation_connectivity_parameters = var.invocation_connectivity_parameters
}
