output "cache_security_group_id" {
  value = "${aws_security_group.redis.id}"
}

# Redis instance for caching
output "redis_cache_hostname" {
  value = "${aws_elasticache_cluster.redis_cache.cache_nodes.0.address}"
}

output "redis_cache_port" {
  value = "${aws_elasticache_cluster.redis_cache.cache_nodes.0.port}"
}

output "redis_cache_endpoint" {
  value = "${join(":", list(aws_elasticache_cluster.redis_cache.cache_nodes.0.address, aws_elasticache_cluster.redis_cache.cache_nodes.0.port))}"
}

output "redis_cache_cluster_id" {
  value = "${aws_elasticache_cluster.redis_cache.cluster_id}"
}

# Redis instance for queuing
output "redis_queue_hostname" {
  value = "${aws_elasticache_cluster.redis_queue.cache_nodes.0.address}"
}

output "redis_queue_port" {
  value = "${aws_elasticache_cluster.redis_queue.cache_nodes.0.port}"
}

output "redis_queue_endpoint" {
  value = "${join(":", list(aws_elasticache_cluster.redis_queue.cache_nodes.0.address, aws_elasticache_cluster.redis_queue.cache_nodes.0.port))}"
}
