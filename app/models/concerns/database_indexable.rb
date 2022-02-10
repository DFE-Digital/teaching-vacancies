module DatabaseIndexable
  extend ActiveSupport::Concern

  included do
    before_save :update_searchable_content

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
        readable_phases,
        VacancyPresenter.new(self).show_job_roles,
        VacancyPresenter.new(self).show_key_stages,
        parent_organisation_name,
        organisations.schools.map { |school| school.school_groups.map(&:name) }.flatten,
        VacancyPresenter.new(self).working_patterns,
        organisations.map(&:name),
        organisations.map(&:county).uniq,
        organisations.schools.map(&:detailed_school_type).uniq,
        organisations.school_groups.map(&:group_type).reject(&:blank?).uniq,
        organisations.map(&:local_authority_within).reject(&:blank?).uniq,
        organisations.schools.map(&:religious_character).reject(&:blank?).uniq,
        organisations.schools.map(&:region).uniq,
        organisations.schools.map { |org| org.school_type&.singularize }.uniq,
        organisations.map(&:town).reject(&:blank?).uniq,
      ],
    ).tsvector
  end

  private

  def unique_words(text)
    return if text.nil?

    text.downcase.scan(/[\w-]+/).uniq
  end
end
