# terraform-aws-elasticache-redis

A Terraform module that represents an AWS ElastiCache Redis cluster.  Note that a default security group is created and outputted that can be extended.  See basic example usage below and more examples [here](/examples).

### Usage

```terraform
provider "aws" {
  region = "us-east-1"
}

module "elasticache_redis" {
  source = "github.com/turnerlabs/terraform-aws-elasticache-redis?ref=v2.2"

  cluster_id         = "myteam-myapp-dev"
  engine_version     = "2.8.24"
  instance_type      = "cache.m3.medium"
  maintenance_window = "sun:05:00-sun:06:00"
  vpc_id             = "vpc-d070efb3"
  private_subnet_ids = "subnet-020d8b59,subnet-13f50b64"

  tag_name          = "myteam-myapp-dev"
  tag_team          = "my-team"
  tag_contact-email = "my-team@turner.com"
  tag_application   = "my-app"
  tag_environment   = "dev"
  tag_customer      = "my-customer"
}
```

### Variables

- `cluster_id` - ID of the cluster
- `vpc_id` - ID of VPC meant to house the cache
- `private_subnet_ids` - Comma delimited list of private subnet IDs
- `engine_version` - Cache engine version (default: `2.8.24`)
- `instance_type` - Instance type for cache instance (default: `cache.m3.medium`)
- `maintenance_window` - 60 minute time window to reserve for maintenance
  (default: `sun:05:00-sun:06:00`)
- `parameter_group_name` - Name of the parameter group to associate with this cache cluster (default: `default.redis2.8`)
- `tag_name`
- `tag_environment`
- `tag_team`
- `tag_application`
- `tag_customer`
- `tag_contact-email`


### Outputs

- `cache_security_group_id` - Security group ID of the cache cluster
- `hostname` - Public DNS name of cache node
- `port` - Port of cache instance
- `endpoint` - Public DNS name and port separated by a `:`
