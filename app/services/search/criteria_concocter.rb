# Based on a vacancy, concoct a plausible set of search criteria for a job alert subscription
class Search::CriteriaConcocter
  attr_reader :criteria

  def initialize(vacancy)
    @vacancy = vacancy
    @criteria = concoct_search_criteria
  end

private

  def concoct_search_criteria
    criteria = {
      location: @vacancy.parent_organisation.postcode,
      working_patterns: @vacancy.working_patterns,
      phases: @vacancy.education_phases,
      job_roles: @vacancy.job_roles,
      keyword: keyword
    }
    criteria[:radius] = '10' if @vacancy.parent_organisation.postcode.present?
    criteria.delete_if { |k, v| v.blank? }
  end

  def keyword
    if @vacancy.subject.present?
      subject
    elsif @vacancy.job_roles.any?
      # Avoid using a hash table here in order to control the order of words.
      # For example, programmatically mapping the job_roles might generate a keyword like
      # 'leader SEN', which is a less appealing search suggestion than the grammatically
      # correct 'SEN leader'.
      keyword = ''
      keyword += 'NQT' if @vacancy.job_roles.include? 'nqt_suitable'
      keyword += 'SEN' if @vacancy.job_roles.include? 'sen_specialist'
      # The word 'leadership' is not in our synonym configuration.
      keyword += 'leader' if @vacancy.job_roles.include? 'leadership'
      keyword += 'teacher' if @vacancy.job_roles.include? 'teacher'
      keyword
    elsif get_subjects_from_job_title.present?
      get_subjects_from_job_title
    elsif get_keywords_from_job_title.present?
      get_keywords_from_job_title
    end
  end

  def get_subjects_from_job_title
    subjects = []
    SUBJECT_OPTIONS.map(&:first).each do |subject|
      subjects << normalize(subject) if normalize(job_title).include?(normalize(subject))
    end
    subjects.join(' ')
  end

  def get_keywords_from_job_title
    keywords = []
    ['teacher', 'head', 'principal', 'sen', 'teaching assistant'].each do |word|
      keywords << normalize(word) if normalize(job_title).include?(normalize(word))
    end
    subjects.join(' ')
  end

  def normalize(string)
    string.downcase.gsub('&', 'and')
  end
end
