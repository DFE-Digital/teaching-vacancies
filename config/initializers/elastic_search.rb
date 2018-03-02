Elasticsearch::Model.client = Elasticsearch::Client.new(host: Figaro.env.ELASTICSEARCH_URL!)
