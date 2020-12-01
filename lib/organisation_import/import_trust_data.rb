require "organisation_import/import_organisation_data"

class ImportTrustData < ImportOrganisationData
  TRUST_TEMP_LOCATION = "./tmp/school-group-data.csv".freeze

  MEMBERSHIP_TEMP_LOCATION = "./tmp/school-group-membership-data.csv".freeze

  WORDS_TO_UPPERCASE = %w[
    aces bmat ce csia ebn ekc epa hcat hcuk hisp hti inmat kwest link mat nas own pa pace pact polymat qed qegsmat rmet rnib rsa sdbe seax sen sendat sfaet step tbap tcat timu tvi uk utc vi xxiii
  ].freeze
  WORDS_TO_TITLECASE = %w[st ltd].freeze
  WORDS_TO_DOWNCASE = %w[of and].freeze

  def run!
    import_data(trust_csv_url, TRUST_TEMP_LOCATION, :create_organisation)
    import_data(membership_csv_url, MEMBERSHIP_TEMP_LOCATION, :create_school_group_membership)
  end

private

  def column_name_mappings
    {
      name: "Group Name",
      address: "Group Locality",
      county: "Group County",
      group_type: "Group Type",
      town: "Group Town",
    }.freeze
  end

  def column_value_transformations
    {
      name: ->(name) { detailed_titlecase(name) },
    }
  end

  def convert_to_organisation(row)
    trust = SchoolGroup.find_or_initialize_by(uid: row["Group UID"])
    set_properties(trust, row)
    set_gias_data_as_json(trust, row)
    set_geolocation(trust, row["Group Postcode"])
    trust
  end

  def create_school_group_membership(row)
    trust = SchoolGroup.find_by(uid: row["Group UID"])
    school = School.find_by(urn: row["URN"])
    SchoolGroupMembership.find_or_create_by(school_id: school.id, school_group_id: trust.id) if
      trust.present? && school.present?
  end

  def datestring
    Time.current.strftime("%Y%m%d")
  end

  def import_data(url, location, method)
    save_csv_file(url, location)
    CSV.foreach(location, headers: true, encoding: "windows-1252:utf-8").each do |row|
      # Only import data for Multi-academy trusts
      next unless row["Group Type (code)"].to_i == 6

      Organisation.transaction do
        send(method, row)
      end
    end
    File.delete(location)
  end

  def membership_csv_url
    "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata#{datestring}.csv"
  end

  def trust_csv_url
    "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata#{datestring}.csv"
  end

  def set_geolocation(trust, postcode)
    # We don't need to make an API request if the postcode hasn't changed
    if postcode.present? && (trust.geolocation.blank? || trust.postcode != postcode)
      trust.postcode = postcode
      coordinates = Geocoding.new(trust.postcode).coordinates
      trust.geolocation = coordinates unless coordinates == [0, 0]
    end
  end

  def detailed_titlecase(name)
    # Exclude acronyms from titlecase transformation, so that e.g. 'GLF SCHOOLS' is 'GLF Schools', not 'Glf Schools'.

    return name unless name == name.upcase

    name.split.map { |word|
      word_without_punctuation = word.downcase.gsub(/\W/, "")

      if WORDS_TO_TITLECASE.include?(word_without_punctuation)
        word.titlecase
      elsif WORDS_TO_DOWNCASE.include?(word_without_punctuation)
        word.downcase
      elsif WORDS_TO_UPPERCASE.include?(word_without_punctuation) || !word.downcase.match?(/[aeiouy]/)
        # Checking that there are no vowels will catch some but not all acronyms.
        # Include 'y' to catch 'Lynn', 'Blyth'.
        word.upcase
      else
        word.titlecase
      end
    }.compact.join(" ").gsub("Co Operative", "Co-operative")
  end
end
