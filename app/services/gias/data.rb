class Gias::Data
  GIAS_BASE_URL = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/".freeze

  include Enumerable

  def initialize(type)
    @type = type
  end

  def each(&block)
    response = HTTParty.get(csv_url)
    raise "Couldn't download GIAS CSV from #{csv_url} (code #{response.code})" unless response.ok?

    Tempfile.create(type) do |file|
      File.write(file, response.body, mode: "wb")

      CSV.foreach(file, headers: true, encoding: "windows-1252:utf-8", &block)
    end
  end

  private

  attr_reader :type

  def csv_url
    timestring = Time.current.strftime("%Y%m%d")

    "#{GIAS_BASE_URL}#{type}#{timestring}.csv"
  end
end
