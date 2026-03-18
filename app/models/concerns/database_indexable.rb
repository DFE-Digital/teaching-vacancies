module DatabaseIndexable
  extend ActiveSupport::Concern
  include ReadableVacancyHelper

  included do
    # during backfills, only update this for live vacancies
    before_save :update_searchable_content, unless: -> { expired? }

    # Performs a full "reindex" on all live and pending vacancies (to be run when weightings for
    # searchable_content have been changed)
    def self.update_all_searchable_content!
      applicable.find_each do |vacancy|
        vacancy.update_columns(searchable_content: vacancy.generate_searchable_content)
      end
    end
  end

  def update_searchable_content
    self.searchable_content = generate_searchable_content
  end

  def generate_searchable_content # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    # For now, this configuration mirrors the current Algolia ranking as closely as possible
    # `job_title` and `subject` are used for ranking (and weighted with 'A' here, the other
    # searchable fields get the lowest possible 'D' weight)
    Search::Postgres::TsvectorGenerator.new(
      a: [unique_words(job_title), subjects],
      d: [
        phases.map(&:humanize),
        vacancy_readable_job_roles(self),
        vacancy_readable_key_stages(self),
        organisation_name,
        school_group_names,
        school_group_types,
        vacancy_readable_working_patterns(self),
        religious_character,
        organisations.map { |org| org.school_type&.singularize }.reject(&:blank?).uniq,
        organisations.map(&:detailed_school_type).reject(&:blank?).uniq,
        organisations.map(&:name),
        organisations.map(&:town).reject(&:blank?).uniq,
        organisations.map(&:local_authority_within).reject(&:blank?).uniq,
        organisations.map(&:county).reject(&:blank?).uniq,
        organisations.map(&:region).reject(&:blank?).uniq,
        vacancy_readable_visa_sponsorship_availability(self),
      ],
      ).tsvector
  end

  private

  def unique_words(text)
    return if text.nil?

    text.downcase.scan(/[\w-]+/).uniq
  end
end
