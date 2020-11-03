# Based on a vacancy, devise a plausible set of search criteria for a job alert subscription
class Search::CriteriaDeviser
  attr_reader :criteria

  def initialize(vacancy)
    @vacancy = vacancy
    @criteria = devise_search_criteria
  end

private

  def devise_search_criteria
    {
      location: @vacancy.parent_organisation.postcode,
      radius: (@vacancy.parent_organisation.postcode.present? ? "10" : nil),
      working_patterns: @vacancy.working_patterns,
      phases: @vacancy.education_phases,
      job_roles: @vacancy.job_roles,
      keyword: keyword
    }.delete_if { |_k, v| v.blank? }
  end

  def keyword
    if @vacancy.subjects.present?
      @vacancy.subjects.join(" ")
    else
      get_subjects_from_job_title.presence || get_keywords_from_job_title.presence
    end
  end

  def get_subjects_from_job_title
    subject_options = SUBJECT_OPTIONS.map(&:first)
    single_word_subjects = subject_options.select { |subject| subject.split(" ").one? }
    multi_word_subjects = subject_options.select { |subject| subject.split(" ").many? }
    keyword = get_strings_from_job_title(single_word_subjects, multi_word_subjects)
    # Hard code synonym 'Maths' for 'Mathematics' - SUBJECT_OPTIONS only contains 'Mathematics'
    keyword << "Mathematics" if normalize(@vacancy.job_title).include?(normalize("Maths"))
    keyword.join(" ")
  end

  def get_keywords_from_job_title
    get_strings_from_job_title(%w[Teacher Head Principal SEN], ["Teaching Assistant"]).join(" ")
  end

  def get_strings_from_job_title(words, phrases)
    words_and_phrases = []
    words.each do |word|
      if normalize(@vacancy.job_title).split(" ").include?(normalize(word))
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
