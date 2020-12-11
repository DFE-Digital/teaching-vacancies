module AWSIpRanges
  # Used based on this AWS instruction: https://forums.aws.amazon.com/ann.jspa?annID=2051
  PATH = "https://ip-ranges.amazonaws.com/ip-ranges.json".freeze
  COMPATIBLE_REGIONS = %w[GLOBAL eu-west-2].freeze

  def self.cloudfront_ips
    uri = URI(PATH)

    begin
      http_connection = Net::HTTP.new(uri.host, uri.port)
      http_connection.read_timeout = 10
      http_connection.open_timeout = 5
      http_connection.use_ssl = true
      response = http_connection.start { |http| http.get(uri.path) }

      parse_json_for_ips(response.body)
    rescue Timeout::Error,
           Errno::EINVAL,
           Errno::ECONNRESET,
           EOFError,
           Net::HTTPBadResponse,
           Net::HTTPHeaderSyntaxError,
           Net::ProtocolError => e
      Rails.logger.warn("Unable to setup Rack Proxies to acquire the correct remote_ip: #{e.class}")
      []
    end
  end

  def self.parse_json_for_ips(response)
    aws_ip_ranges = JSON.parse(response)

    cloudfront_ip_blocks = aws_ip_ranges["prefixes"].select do |record|
      COMPATIBLE_REGIONS.include?(record["region"]) && record["service"] == "CLOUDFRONT"
    end
    cloudfront_ip_blocks.map { |cloudfront_ip| cloudfront_ip["ip_prefix"] }
  rescue JSON::ParserError
    Rails.logger.warn("Unable parse AWS Ip Range response to setup Rack Proxies")
    []
  end
end
