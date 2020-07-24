output web_app_endpoint {
  value       = cloudfoundry_route.web_app_route.endpoint
  description = "URL for the web application"
}

output tf_workspace {
  value       = terraform.workspace
  description = "The terraform workspace"
}
