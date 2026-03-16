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

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the connection. Must be unique within the region. Length 1-64. Pattern: ^[0-9A-Za-z_.-]+"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 64
    error_message = "Name must be between 1 and 64 characters."
  }

  validation {
    condition     = can(regex("^[0-9A-Za-z_.-]+$", var.name))
    error_message = "Name must match pattern ^[0-9A-Za-z_.-]+"
  }
}

variable "authorization_type" {
  description = "Type of authorization to use. One of: API_KEY, BASIC, OAUTH_CLIENT_CREDENTIALS"
  type        = string

  validation {
    condition     = contains(["API_KEY", "BASIC", "OAUTH_CLIENT_CREDENTIALS"], var.authorization_type)
    error_message = "Authorization type must be API_KEY, BASIC, or OAUTH_CLIENT_CREDENTIALS."
  }
}

variable "auth_parameters" {
  description = <<-EOT
    Authentication parameters. Exactly one of api_key, basic, or oauth must be set based on authorization_type.
    - api_key: For API_KEY - key and value
    - basic: For BASIC - username and password
    - oauth: For OAUTH_CLIENT_CREDENTIALS - authorization_endpoint, http_method, client_parameters, oauth_http_parameters
    - invocation_http_parameters: Optional - body, header, query_string params for each invocation
  EOT
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

  validation {
    condition = (
      (try(var.auth_parameters.api_key, null) != null ? 1 : 0) +
      (try(var.auth_parameters.basic, null) != null ? 1 : 0) +
      (try(var.auth_parameters.oauth, null) != null ? 1 : 0)
    ) == 1
    error_message = "Exactly one of auth_parameters.api_key, auth_parameters.basic, or auth_parameters.oauth must be set."
  }
}

# -----------------------------------------------------------------------------
# Optional
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the connection. Length 0-512."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || (length(var.description) >= 0 && length(var.description) <= 512)
    error_message = "Description must be between 0 and 512 characters."
  }
}

variable "invocation_connectivity_parameters" {
  description = "Connectivity parameters for invocation (e.g., VPC Lattice). Used for private API access."
  type = object({
    resource_parameters = object({
      resource_configuration_arn = string
    })
  })
  default = null
}

variable "kms_key_identifier" {
  description = "ARN of the KMS key used to encrypt the connection credentials in Secrets Manager. Omit for AWS-managed encryption."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_identifier == null || (length(var.kms_key_identifier) >= 0 && length(var.kms_key_identifier) <= 2048)
    error_message = "KMS key identifier must be between 0 and 2048 characters."
  }
}
