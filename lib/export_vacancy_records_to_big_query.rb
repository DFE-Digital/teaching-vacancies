require 'google/cloud/bigquery'

class ExportVacancyRecordsToBigQuery
  attr_reader :dataset

  def initialize(bigquery: Google::Cloud::Bigquery.new)
    @dataset = bigquery.dataset ENV.fetch('BIG_QUERY_DATASET')
  end

  def run!(batch_size: 1_000)
    delete_table
    Vacancy.all.find_in_batches batch_size: batch_size do |batch|
      insert_table_data(batch)
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def present_for_big_query(batch)
    batch.map do |v|
      {
        id: v.id,
        slug: v.slug,
        job_title: v.job_title,
        minimum_salary: v.minimum_salary,
        maximum_salary: v.maximum_salary,
        starts_on: format_as_date(v.starts_on),
        ends_on: format_as_date(v.ends_on),
        subjects: subjects(v),
        min_pay_scale: v.min_pay_scale&.label,
        max_pay_scale: v.max_pay_scale&.label,
        leadership: v.leadership&.title,
        education: v.education,
        qualifications: v.qualifications,
        experience: v.experience,
        status: v.status,
        expiry_time: expiry_time(v),
        publish_on: format_as_timestamp(v.publish_on),
        school: {
          urn: v.school.urn,
          county: v.school.county,
        },
        created_at: v.created_at,
        updated_at: v.updated_at,
        application_link: v.application_link,
        newly_qualified_teacher: v.newly_qualified_teacher,
        total_pageviews: v.total_pageviews,
        total_get_more_info_clicks: v.total_get_more_info_clicks,
        working_patterns: v.working_patterns,
        listed_elsewhere: v.listed_elsewhere,
        hired_status: v.hired_status,
        pro_rata_salary: v.pro_rata_salary,
        publisher_user_id: v.publisher_user&.oid,
      }
    end
  end

  def insert_table_data(batch)
    dataset.insert 'vacancies', present_for_big_query(batch), autocreate: true do |schema|
      schema.string 'id', mode: :required
      schema.string 'slug', mode: :required
      schema.string 'job_title', mode: :required
      schema.string 'minimum_salary', mode: :required
      schema.string 'maximum_salary', mode: :nullable
      schema.date 'starts_on', mode: :nullable
      schema.date 'ends_on', mode: :nullable
      schema.string 'subjects', mode: :repeated

      schema.string 'min_pay_scale', mode: :nullable
      schema.string 'max_pay_scale', mode: :nullable
      schema.string 'leadership', mode: :nullable

      schema.string 'education', mode: :nullable
      schema.string 'qualifications', mode: :nullable
      schema.string 'experience', mode: :nullable
      schema.string 'status', mode: :required

      schema.timestamp 'expiry_time', mode: :nullable
      schema.timestamp 'publish_on', mode: :nullable

      schema.record 'school', mode: :nullable do |school|
        school.string 'urn', mode: :required
        school.string 'county', mode: :nullable
      end

      schema.timestamp 'created_at', mode: :required
      schema.timestamp 'updated_at', mode: :required

      schema.string 'application_link', mode: :nullable

      schema.boolean 'newly_qualified_teacher', mode: :required

      schema.integer 'total_pageviews', mode: :nullable
      schema.integer 'total_get_more_info_clicks', mode: :nullable
      schema.string 'working_patterns', mode: :repeated

      schema.string 'listed_elsewhere', mode: :nullable
      schema.string 'hired_status', mode: :nullable
      schema.boolean 'pro_rata_salary', mode: :nullable

      schema.string 'publisher_user_id', mode: :nullable
    end
  end
  # rubocop:enable Metrics/AbcSize

  def format_as_date(date)
    date&.strftime('%F')
  end

  def delete_table
    table = dataset.table 'vacancies'
    return if table.nil?
    dataset.reload! if table.delete
  end

  def format_as_timestamp(datetime)
    datetime&.strftime('%FT%T%:z')
  end

  def expiry_time(vacancy)
    vacancy.expiry_time || format_as_timestamp(vacancy.expires_on)
  end

  def subjects(vacancy)
    subjects = []

    subjects << vacancy.subject if vacancy.subject
    subjects << vacancy.first_supporting_subject if vacancy.first_supporting_subject
    subjects << vacancy.second_supporting_subject if vacancy.second_supporting_subject

    subjects.map(&:name)
  end
end
