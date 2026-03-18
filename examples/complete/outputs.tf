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

output "id" {
  description = "The ID of the connection."
  value       = module.event_connection.id
}

output "arn" {
  description = "The ARN of the connection."
  value       = module.event_connection.arn
}

output "name" {
  description = "The name of the connection."
  value       = module.event_connection.name
}

output "secret_arn" {
  description = "The ARN of the secret in Secrets Manager."
  value       = module.event_connection.secret_arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the connection credentials."
  value       = aws_kms_key.connection.arn
}
