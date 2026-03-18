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

variable "resource_names_map" {
  description = "Map of key to resource_name config for the resource_name module. Each value's name (cloud_resource_type) must be alphanumeric only (no underscores), e.g. eventconnection01, kmskey01."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "logical_product_family" {
  description = "Logical product family for resource naming."
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service for resource naming."
  type        = string
}

variable "class_env" {
  description = "Class environment for resource naming (e.g., dev, prod)."
  type        = string
}

variable "instance_env" {
  description = "Instance environment index for resource naming."
  type        = number
}

variable "instance_resource" {
  description = "Instance resource index for resource naming."
  type        = number
}

variable "authorization_type" {
  description = "Type of authorization. One of: API_KEY, BASIC, OAUTH_CLIENT_CREDENTIALS"
  type        = string
}

variable "auth_parameters" {
  description = "Authentication parameters. Exactly one of api_key, basic, or oauth must be set."
  type = object({
    api_key = optional(object({
      key   = string
      value = string
    }))
    basic = optional(object({
      username = string
      password = string
    }))
    oauth = optional(object({
      authorization_endpoint = string
      http_method            = string
      client_parameters = optional(object({
        client_id     = string
        client_secret = string
      }))
      oauth_http_parameters = object({
        body = optional(list(object({
          key             = optional(string)
          value           = optional(string)
          is_value_secret = optional(bool, false)
        })), [])
        header = optional(list(object({
          key             = optional(string)
          value           = optional(string)
          is_value_secret = optional(bool, false)
        })), [])
        query_string = optional(list(object({
          key             = optional(string)
          value           = optional(string)
          is_value_secret = optional(bool, false)
        })), [])
      })
    }))
    invocation_http_parameters = optional(object({
      body = optional(list(object({
        key             = optional(string)
        value           = optional(string)
        is_value_secret = optional(bool, false)
      })), [])
      header = optional(list(object({
        key             = optional(string)
        value           = optional(string)
        is_value_secret = optional(bool, false)
      })), [])
      query_string = optional(list(object({
        key             = optional(string)
        value           = optional(string)
        is_value_secret = optional(bool, false)
      })), [])
    }))
  })
}

variable "description" {
  description = "Description of the connection."
  type        = string
  default     = null
}

variable "invocation_connectivity_parameters" {
  description = "Connectivity parameters for invocation (e.g., VPC Lattice)."
  type = object({
    resource_parameters = object({
      resource_configuration_arn = string
    })
  })
  default = null
}

variable "tags" {
  description = "Map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "kms_deletion_window_in_days" {
  description = "Number of days before KMS key is deleted."
  type        = number
  default     = 7
}

variable "kms_enable_key_rotation" {
  description = "Whether to enable automatic key rotation for the KMS key."
  type        = bool
  default     = true
}
