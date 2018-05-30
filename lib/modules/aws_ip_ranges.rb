module AWSIpRanges
  # Used based on this AWS instruction: https://forums.aws.amazon.com/ann.jspa?annID=2051
  PATH = 'https://ip-ranges.amazonaws.com/ip-ranges.json'.freeze

  def self.cloudfront_ips
    uri = URI(PATH)

    begin
      response = Net::HTTP.get(uri)
      return parse_json_for_ips(response)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      Rails.logger.warn("Unable to setup Rack Proxies to acquire the correct remote_ip: #{error.class}")
      return []
    end
  end

  def self.parse_json_for_ips(response)
    aws_ip_ranges = JSON.parse(response)
    cloudfront_ip_blocks = aws_ip_ranges['prefixes'].select do |record|
      record['region'] == 'GLOBAL' && record['service'] == 'CLOUDFRONT'
    end
    cloudfront_ip_blocks.map { |cloudfront_ip| cloudfront_ip['ip_prefix'] }
  end
end
