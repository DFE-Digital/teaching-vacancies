module Ip
  extend ActiveSupport::Concern

  def request_ip
    remove_the_last_octet(request.ip)
  end

  def remove_the_last_octet(ip)
    # Strip everything after and including the third decimal
    "#{ip.gsub(/[^.]*.[^.]*.[^.]*\K.*$/, '')}…"
  end
end
