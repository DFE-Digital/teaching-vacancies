require "csv"

class Gias::Data
  GIAS_BASE_URL = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/".freeze

  include Enumerable

  def initialize(type)
    @type = type
  end

  def each(&)
    Tempfile.create(type) do |file|
      file.binmode

      # If a retry kicks in mid-download, discard whatever was already written so the
      # retried attempt doesn't get appended after a partial/corrupt download.
      retry_options = { retry_block: proc {
        file.truncate(0)
        file.rewind
      } }

      response = HttpClient.connection(retry_options: retry_options).get(csv_url) do |req|
        req.headers["User-Agent"] = "teaching-vacancies"
        req.options.on_data = proc do |chunk, _bytes_received, env|
          file.write(chunk) if env.status == 200
        end
      end
      raise "Could not download file #{csv_url} from GIAS: #{response.status}" unless response.status == 200

      file.rewind

      CSV.foreach(file, headers: true, encoding: "windows-1252:utf-8", &)
    end
  end

  private

  attr_reader :type

  def csv_url
    timestring = Time.current.strftime("%Y%m%d")

    "#{GIAS_BASE_URL}#{type}#{timestring}.csv"
  end
end
