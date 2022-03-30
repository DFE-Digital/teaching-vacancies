class ApplyClient
  def self.recruited_candidates_csv(...)
    new.recruited_candidates_csv(...)
  end

  def recruited_candidates_csv(recruitment_cycle_year:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    CSV.generate do |csv|
      csv << ["Email address", "Recruitment cycle year", "Application status"]

      page = 1
      stats = {
        application_count: 0,
        by_cycle_year: Hash.new { |hash, key| hash[key] = Hash.new(0) },
      }
      until (data = fetch_page(page)).blank?
        recruited_count = 0
        data.each do |candidate|
          forms = candidate.dig(:attributes, :application_forms) || []
          forms.each do |f|
            stats[:application_count] += 1
            stats[:by_cycle_year][f[:recruitment_cycle_year]][f[:application_status]] += 1
          end

          next unless forms.any? do |f|
            f[:application_status] == "recruited" && f[:recruitment_cycle_year] == recruitment_cycle_year
          end

          recruited_count += 1
          csv << [candidate.dig(:attributes, :email_address), recruitment_cycle_year.to_s, "recruited"]
        end

        puts "#{data.size} checked, #{recruited_count} found"

        page += 1
      end

      puts "done."

      pp stats
    end
  end

  private

  def fetch_page(page)
    print "Loading page #{page}.. "
    uri = uri_for_path("/candidate-api/candidates", page: page)
    request = request_for_uri(uri)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body, symbolize_names: true)[:data]
  end

  def uri_for_path(path, updated_since: "2010-01-01", page: nil)
    URI(ENV.fetch("APPLY_API_ENDPOINT")).tap do |u|
      u.path = path
      u.query = "updated_since=#{updated_since}&page=#{page}"
    end
  end

  def request_for_uri(uri)
    Net::HTTP::Get.new(uri).tap do |r|
      r["Authorization"] = "Bearer #{ENV.fetch('APPLY_API_KEY')}"
      r["Accept"] = "application/json"
    end
  end
end
