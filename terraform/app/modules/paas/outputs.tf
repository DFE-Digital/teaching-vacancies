output docker_image {
  value       = cloudfoundry_app.web_app.docker_image
  description = "Docker image - repository:tag"
}

output docker_tag {
  value = regex(":(.*)$", cloudfoundry_app.web_app.docker_image)[0]
}
