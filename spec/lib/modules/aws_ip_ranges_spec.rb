require "rails_helper"
require "modules/aws_ip_ranges"

RSpec.describe AWSIpRanges do
  describe ".cloudfront_ips" do
    before do
      aws_ip_ranges = file_fixture("aws_ip_ranges.json")
      stub_request(:get, AWSIpRanges::PATH).to_return(body: aws_ip_ranges, status: 200)
    end

    it "returns the CLOUDFRONT ip in the GLOBAL or eu-west-2 area" do
      expected_result = %w[
        13.32.0.0/15
        13.35.0.0/16
        52.46.0.0/18
        52.56.127.0/25
        52.84.0.0/15
        52.124.128.0/17
        52.222.128.0/17
        54.182.0.0/16
        54.192.0.0/16
        54.230.0.0/16
        54.239.128.0/18
        54.239.192.0/19
        54.240.128.0/18
        64.252.64.0/18
        70.132.0.0/18
        71.152.0.0/17
        143.204.0.0/16
        204.246.164.0/22
        204.246.168.0/22
        204.246.174.0/23
        204.246.176.0/20
        205.251.192.0/19
        205.251.249.0/24
        205.251.250.0/23
        205.251.252.0/23
        205.251.254.0/24
        216.137.32.0/19
      ]

      expect(AWSIpRanges.cloudfront_ips).to eq(expected_result)
    end

    it "configures a short timeout" do
      http_connection_double = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_connection_double)

      expect(http_connection_double).to receive(:read_timeout=).with(10)
      expect(http_connection_double).to receive(:open_timeout=).with(5)
      expect(http_connection_double).to receive(:use_ssl=).with(true)

      # Check same object is the one used for the request
      successful_response = instance_double(Net::HTTPOK, body: "")
      expect(http_connection_double).to receive(:start).and_return(successful_response)

      AWSIpRanges.cloudfront_ips
    end

    context "when there was any connectivity issue" do
      it "returns an empty array" do
        allow_any_instance_of(Net::HTTP).to receive(:start).and_raise(Timeout::Error.new("error"))
        expect(AWSIpRanges.cloudfront_ips).to eq([])
      end

      it "logs a warning" do
        allow_any_instance_of(Net::HTTP).to receive(:start).and_raise(Timeout::Error.new("error"))
        expect(Rails.logger)
          .to receive(:warn)
          .with("Unable to setup Rack Proxies to acquire the correct remote_ip: Timeout::Error")
        AWSIpRanges.cloudfront_ips
      end
    end

    context "when we see other types of Net::HTTP error" do
      [
        Errno::EINVAL,
        Errno::ECONNRESET,
        EOFError,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError,
        Net::OpenTimeout,
      ].each do |error|
        context "when #{error} is raised" do
          it "returns an empty array" do
            allow_any_instance_of(Net::HTTP).to receive(:start).and_raise(error.new("error"))
            expect(AWSIpRanges.cloudfront_ips).to eq([])
          end
        end
      end
    end

    context "when the response was 403 and not JSON" do
      before(:each) do
        aws_ip_ranges = file_fixture("bad_aws_ip_ranges.xml")
        stub_request(:get, AWSIpRanges::PATH).to_return(body: aws_ip_ranges, status: 403)
      end

      it "returns an empty array" do
        expect(AWSIpRanges.cloudfront_ips).to eq([])
      end

      it "logs a warning" do
        expect(Rails.logger)
          .to receive(:warn)
          .with("Unable parse AWS Ip Range response to setup Rack Proxies")
        AWSIpRanges.cloudfront_ips
      end
    end
  end
end
