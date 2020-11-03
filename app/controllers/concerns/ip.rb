module Ip
  require "ipaddr"

  extend ActiveSupport::Concern

  def request_ip
    anonymize_ip(request.remote_ip)
  end

  def anonymize_ip(ip_string)
    ip = IPAddr.new(ip_string)

    return anonymize_ipv4(ip) if ip.ipv4?
    return anonymize_ipv6(ip) if ip.ipv6?
  rescue StandardError
    nil
  end

  def anonymize_ipv4(ip)
    ip_parts = ip.to_s.split "."

    ip_parts[ip_parts.count - 1] = "0"

    IPAddr.new(ip_parts.join(".")).to_s
  end

  def anonymize_ipv6(ip)
    ip_parts = ip.to_s.split ":"

    ip_string = ip_parts[0..2].join(":") + ":0000:0000:0000:0000:0000"

    IPAddr.new(ip_string).to_s
  end
end
