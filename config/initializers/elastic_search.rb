Elasticsearch::Model.client = Elasticsearch::Client.new(host: Figaro.env.elastic_search_endpoint!)
