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

resource "aws_cloudwatch_event_connection" "connection" {
  name               = var.name
  authorization_type = var.authorization_type
  description        = var.description

  auth_parameters {
    dynamic "api_key" {
      for_each = var.auth_parameters.api_key != null ? [var.auth_parameters.api_key] : []
      content {
        key   = api_key.value.key
        value = api_key.value.value
      }
    }

    dynamic "basic" {
      for_each = var.auth_parameters.basic != null ? [var.auth_parameters.basic] : []
      content {
        username = basic.value.username
        password = basic.value.password
      }
    }

    dynamic "oauth" {
      for_each = var.auth_parameters.oauth != null ? [var.auth_parameters.oauth] : []
      content {
        authorization_endpoint = oauth.value.authorization_endpoint
        http_method            = oauth.value.http_method

        dynamic "client_parameters" {
          for_each = oauth.value.client_parameters != null ? [oauth.value.client_parameters] : []
          content {
            client_id     = client_parameters.value.client_id
            client_secret = client_parameters.value.client_secret
          }
        }

        dynamic "oauth_http_parameters" {
          for_each = oauth.value.oauth_http_parameters != null ? [oauth.value.oauth_http_parameters] : []
          content {
            dynamic "body" {
              for_each = oauth_http_parameters.value.body != null ? oauth_http_parameters.value.body : []
              content {
                key             = body.value.key
                value           = body.value.value
                is_value_secret = coalesce(body.value.is_value_secret, false)
              }
            }
            dynamic "header" {
              for_each = oauth_http_parameters.value.header != null ? oauth_http_parameters.value.header : []
              content {
                key             = header.value.key
                value           = header.value.value
                is_value_secret = coalesce(header.value.is_value_secret, false)
              }
            }
            dynamic "query_string" {
              for_each = oauth_http_parameters.value.query_string != null ? oauth_http_parameters.value.query_string : []
              content {
                key             = query_string.value.key
                value           = query_string.value.value
                is_value_secret = coalesce(query_string.value.is_value_secret, false)
              }
            }
          }
        }
      }
    }

    dynamic "invocation_http_parameters" {
      for_each = var.auth_parameters.invocation_http_parameters != null ? [var.auth_parameters.invocation_http_parameters] : []
      content {
        dynamic "body" {
          for_each = invocation_http_parameters.value.body != null ? invocation_http_parameters.value.body : []
          content {
            key             = body.value.key
            value           = body.value.value
            is_value_secret = coalesce(body.value.is_value_secret, false)
          }
        }
        dynamic "header" {
          for_each = invocation_http_parameters.value.header != null ? invocation_http_parameters.value.header : []
          content {
            key             = header.value.key
            value           = header.value.value
            is_value_secret = coalesce(header.value.is_value_secret, false)
          }
        }
        dynamic "query_string" {
          for_each = invocation_http_parameters.value.query_string != null ? invocation_http_parameters.value.query_string : []
          content {
            key             = query_string.value.key
            value           = query_string.value.value
            is_value_secret = coalesce(query_string.value.is_value_secret, false)
          }
        }
      }
    }
  }

  dynamic "invocation_connectivity_parameters" {
    for_each = var.invocation_connectivity_parameters != null ? [var.invocation_connectivity_parameters] : []
    content {
      dynamic "resource_parameters" {
        for_each = invocation_connectivity_parameters.value.resource_parameters != null ? [invocation_connectivity_parameters.value.resource_parameters] : []
        content {
          resource_configuration_arn = resource_parameters.value.resource_configuration_arn
        }
      }
    }
  }

  kms_key_identifier = var.kms_key_identifier
}
