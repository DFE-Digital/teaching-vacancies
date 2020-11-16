output docker_image {
  value       = module.paas.docker_image
  description = "Docker image - repository:tag"
}

output docker_tag {
  value       = module.paas.docker_tag
  description = "Docker tag"
}


output workspace {
  value = terraform.workspace
}
