output docker_image {
  value       = module.paas.docker_image
  description = "Docker image - repository:tag"
}

output workspace {
  value = terraform.workspace
}
