# Based on a vacancy, devise a plausible set of search criteria for a job alert subscription
class Search::CriteriaInventor
  attr_reader :criteria

  DEFAULT_RADIUS_IN_MILES = 25

  def initialize(vacancy)
    @vacancy = vacancy
    @location = location
    @subjects = subjects
    @criteria = set_criteria
  end

  private

  def set_criteria
    { location: @location,
      radius: (@location.present? ? DEFAULT_RADIUS_IN_MILES.to_s : nil),
      working_patterns: [],
      phases: @vacancy.readable_phases,
      job_roles: @vacancy.job_roles,
      subjects: @subjects,
      keyword: }.delete_if { |_k, v| v.blank? }
  end

  def keyword
    return if @vacancy.subjects&.many?
    return @vacancy.subjects.first if @vacancy.subjects&.one?
    return @subjects_from_job_title.first if @subjects_from_job_title.one?

    get_keywords_from_job_title.presence unless @vacancy.job_roles.present?
  end

  def location
    return @vacancy.organisation.postcode if @vacancy.organisations.one?

    @vacancy.postcode_from_mean_geolocation || @vacancy.set_postcode_from_mean_geolocation || @vacancy.parent_organisation.postcode
  end

  def subjects
    return if @vacancy.subjects&.one?
    return @vacancy.subjects if @vacancy.subjects&.many?

    get_subjects_from_job_title
    @subjects_from_job_title if @subjects_from_job_title.many?
  end

  def get_subjects_from_job_title
    subject_options = SUBJECT_OPTIONS.map(&:first)
    single_word_subjects = subject_options.select { |subject| subject.split.one? }
    multi_word_subjects = subject_options.select { |subject| subject.split.many? }
    subjects = get_strings_from_job_title(single_word_subjects, multi_word_subjects)
    # Hard code synonym 'Maths' for 'Mathematics' - SUBJECT_OPTIONS only contains 'Mathematics'
    subjects << "Mathematics" if normalize(@vacancy.job_title).include?(normalize("Maths"))
    @subjects_from_job_title = subjects
  end

  def get_keywords_from_job_title
    get_strings_from_job_title(%w[Teacher Head Principal SEN], ["Teaching Assistant"]).join(" ")
  end

  def get_strings_from_job_title(words, phrases)
    words_and_phrases = []
    words.each do |word|
      # Split normalised job title on forward slash, comma or whitespace
      if normalize(@vacancy.job_title).split(%r{[/,\s]+}).include?(normalize(word))
        words_and_phrases << word
      end
    end
    phrases.each do |phrase|
      if normalize(@vacancy.job_title).include?(normalize(phrase))
        words_and_phrases << phrase
      end
    end
    words_and_phrases
  end

  def normalize(string)
    string.downcase.gsub("&", "and")
  end
end
