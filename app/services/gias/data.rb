class Gias::Data
  GIAS_BASE_URL = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/".freeze

  include Enumerable

  def initialize(type)
    @type = type
  end

  def each(&)
    Tempfile.create(type) do |file|
      file.binmode

      HTTParty.get(csv_url, stream_body: true) do |fragment|
        raise "Could not download file #{csv_url} from GIAS: #{fragment.code}" unless fragment.code == 200

        file.write(fragment)
      end
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
