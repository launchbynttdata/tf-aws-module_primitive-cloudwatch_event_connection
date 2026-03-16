resource_names_map = {
  "event_connection" = {
    name       = "eventconnection01"
    max_length = 64
  }
  "kms_key" = {
    name       = "kmskey01"
    max_length = 256
  }
}

logical_product_family  = "launch"
logical_product_service = "eventbridge"
class_env               = "dev"
instance_env            = 0
instance_resource       = 0

authorization_type = "API_KEY"

auth_parameters = {
  api_key = {
    key   = "x-api-key"
    value = "test-api-key-value-for-terratest"
  }
}

description = "EventBridge connection for API destination (Terratest)"

tags = {
  Environment = "test"
  Terraform   = "true"
}

kms_deletion_window_in_days = 7
kms_enable_key_rotation     = true
