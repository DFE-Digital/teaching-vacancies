Elasticsearch::Model.client = Elasticsearch::Client.new(host: Figaro.env.elasticsearch_url!)
