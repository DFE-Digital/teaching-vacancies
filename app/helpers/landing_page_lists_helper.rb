module LandingPageListsHelper
  TEACHING_ROLES_LIST = {
    "teacher-jobs" => "teacher",
    "head-of-year-or-phase-jobs" => "head_of_year_or_phase",
    "head-of-department-or-curriculum-jobs" => "head_of_department_or_curriculum",
    "assistant-headteacher-jobs" => "assistant_headteacher",
    "deputy-headteacher-jobs" => "deputy_headteacher",
    "headteacher-jobs" => "headteacher",
    "sendco-jobs" => "sendco",
    "other-leadership-roles-jobs" => "other_leadership",
  }.freeze

  SUPPORT_ROLES_LIST = {
    "teaching-assistant-jobs" => "teaching_assistant",
    "higher-level-teaching-assistant-jobs" => "higher_level_teaching_assistant",
    "education-support-jobs" => "education_support",
    "administration-hr-data-finance-jobs" => "administration_hr_data_and_finance",
    "catering-cleaning-site-management-jobs" => "catering_cleaning_and_site_management",
    "it-support-jobs" => "it_support",
    "pastoral-health-welfare-jobs" => "pastoral_health_and_welfare",
    "other-support-roles-jobs" => "other_support",
  }.freeze

  PHASES_LIST = {
    "nursery-jobs" => "nursery",
    "primary-school-jobs" => "primary",
    "secondary-school-jobs" => "secondary",
    "sixth-form-or-college-jobs" => "sixth_form_or_college",
    "through-school-jobs" => "through",
  }.freeze

  WORKING_PATTERNS_LIST = {
    "full-time-school-jobs" => "full_time",
    "part-time-school-jobs" => "part_time",
    "school-job-shares" => "job_share",
    "school-term-time-jobs" => "part_time",
    "flexible-working-jobs-in-schools" => "part_time",
  }.freeze

  FE_WORKING_PATTERNS_LIST = {
    "full-time-fe-jobs" => "full_time",
    "part-time-fe-jobs" => "part_time",
    "fe-job-shares" => "job_share",
  }.freeze

  FE_TEACHING_ROLES_LIST = {
    "fe-teacher-jobs" => "teacher",
    "fe-head-of-year-or-phase-jobs" => "head_of_year_or_phase",
    "fe-head-of-department-or-curriculum-jobs" => "head_of_department_or_curriculum",
    "fe-assistant-headteacher-jobs" => "assistant_headteacher",
    "fe-deputy-headteacher-jobs" => "deputy_headteacher",
    "fe-headteacher-jobs" => "headteacher",
    "fe-sendco-jobs" => "sendco",
    "fe-other-leadership-roles-jobs" => "other_leadership",
  }.freeze

  FE_SUPPORT_ROLES_LIST = {
    "fe-teaching-assistant-jobs" => "teaching_assistant",
    "fe-higher-level-teaching-assistant-jobs" => "higher_level_teaching_assistant",
    "fe-education-support-jobs" => "education_support",
    "fe-administration-hr-data-finance-jobs" => "administration_hr_data_and_finance",
    "fe-catering-cleaning-site-management-jobs" => "catering_cleaning_and_site_management",
    "fe-it-support-jobs" => "it_support",
    "fe-pastoral-health-welfare-jobs" => "pastoral_health_and_welfare",
    "fe-other-support-roles-jobs" => "other_support",
  }.freeze

  LEFT_SUBJECT_LIST = { "maths-teacher-jobs" => "Mathematics",
                        "english-media-studies-teacher-jobs" => "English and Media Studies",
                        "physical-education-teacher-jobs" => "Physical education",
                        "dance-drama-music-teacher-jobs" => "Dance, Drama and Music",
                        "science-teacher-jobs" => "Science" }.freeze

  MIDDLE_SUBJECT_LIST = {
    "history-teacher-jobs" => "History",
    "geography-teacher-jobs" => "Geography",
    "mfl-teacher-jobs" => "Foreign Languages",
  }.freeze

  RIGHT_SUBJECT_LIST = {
    "ict-computer-science-teacher-jobs" => "ICT and Computer Science",
    "economics-business-studies-teacher-jobs" => "Economics and Business Studies",
    "art-design-teacher-jobs" => "Art and design",
    "design-technology-teacher-jobs" => "Design and technology",
    "food-technology-teacher-jobs" => "Food technology",
    "politics-humanities-social-sciences-teacher-jobs" => "Politics, Humanities and Social Sciences",
    "psychology-philosophy-sociology-re-teacher-jobs" => "Psychology, Sociology and RE",
    "health-relationships-social-care-teacher-jobs" => "Health and Social Care",
  }.freeze

  SUBJECTS_COLUMNS = [
    LEFT_SUBJECT_LIST.keys,
    MIDDLE_SUBJECT_LIST.keys,
    RIGHT_SUBJECT_LIST.keys,
  ].freeze

  SUBJECTS_LIST = LEFT_SUBJECT_LIST.merge(MIDDLE_SUBJECT_LIST)
                                   .merge(RIGHT_SUBJECT_LIST)
                                   .freeze

  CHILD_SUBJECTS_LIST = {
    Spanish: "spanish-teacher-jobs",
    French: "french-teacher-jobs",
    Mandarin: "mandarin-teacher-jobs",
    German: "german-teacher-jobs",
    Classics: "classics-latin-teacher-jobs",
    Biology: "biology-teacher-jobs",
    Chemistry: "chemistry-teacher-jobs",
    Physics: "physics-teacher-jobs",
  }.freeze

  FE_SUBJECTS_COLUMNS = [
    %w[
      accountancy-and-finance-fe-jobs
      agriculture-horticulture-land-based-studies-fe-jobs
      animal-care-fe-jobs
      art-and-design-fe-jobs
      biology-fe-jobs
      british-sign-language-fe-jobs
      building-and-construction-fe-jobs
      catering-fe-jobs
      chemistry-fe-jobs
      childrens-development-and-learning-fe-jobs
      classics-fe-jobs
      computer-science-fe-jobs
      construction-fe-jobs
      counselling-fe-jobs
      customer-service-fe-jobs
      dance-drama-and-music-fe-jobs
      design-and-technology-fe-jobs
      early-years-fe-jobs
      economics-and-business-studies-fe-jobs
      electrics-fe-jobs
      engineering-fe-jobs
      english-and-media-studies-fe-jobs
      english-as-a-foreign-language-fe-jobs
    ],
    %w[
      fabrication-and-welding-fe-jobs
      farming-fe-jobs
      fashion-fe-jobs
      food-technology-fe-jobs
      foreign-languages-fe-jobs
      french-fe-jobs
      functional-skills-fe-jobs
      games-design-fe-jobs
      geography-fe-jobs
      german-fe-jobs
      graphic-design-fe-jobs
      hair-and-beauty-fe-jobs
      health-and-social-care-fe-jobs
      history-fe-jobs
      hotel-catering-and-travel-fe-jobs
      humanities-fe-jobs
      ict-and-computer-science-fe-jobs
      land-and-property-management-fe-jobs
      leadership-and-management-fe-jobs
      logistics-fe-jobs
      mandarin-fe-jobs
      maths-fe-jobs
    ],
    %w[
      modern-foreign-languages-fe-jobs
      motor-vehicle-fe-jobs
      music-fe-jobs
      people-management-fe-jobs
      philosophy-fe-jobs
      photography-fe-jobs
      physical-education-fe-jobs
      physics-fe-jobs
      plumbing-and-heating-fe-jobs
      politics-fe-jobs
      pshe-fe-jobs
      psychology-fe-jobs
      public-services-fe-jobs
      religious-education-fe-jobs
      science-fe-jobs
      send-fe-jobs
      sociology-fe-jobs
      spanish-fe-jobs
      sport-and-leisure-fe-jobs
      sports-science-fe-jobs
      tourism-fe-jobs
      welsh-fe-jobs
      woodworking-joinery-and-carpentry-fe-jobs
    ],
  ].freeze

  FE_SUBJECTS_LIST = Rails.application.config.landing_pages
    .select { |_, v| v[:organisation_types] == %w[Colleges] && v.key?(:subjects) }
    .transform_keys(&:to_s)
    .transform_values { |v| v[:subjects].first }
    .freeze

  def landing_page_teaching_roles_list = TEACHING_ROLES_LIST
  def landing_page_support_roles_list = SUPPORT_ROLES_LIST
  def landing_page_phases_list = PHASES_LIST
  def landing_page_working_patterns_list = WORKING_PATTERNS_LIST
  def landing_page_fe_working_patterns_list = FE_WORKING_PATTERNS_LIST
  def landing_page_fe_teaching_roles_list = FE_TEACHING_ROLES_LIST
  def landing_page_fe_support_roles_list = FE_SUPPORT_ROLES_LIST
  def landing_page_subjects_columns = SUBJECTS_COLUMNS
  def landing_page_subjects_list = SUBJECTS_LIST
  def child_subjects_list = CHILD_SUBJECTS_LIST
  def landing_page_fe_subjects_list = FE_SUBJECTS_LIST
  def landing_page_fe_subjects_columns = FE_SUBJECTS_COLUMNS

  def landing_page_tallier(counts_by_subject)
    SUBJECTS_LIST.to_h do |landing_page, subject|
      subject_list = VacancyCounter::GROUPED_SUBJECTS.fetch(subject.to_sym, [subject.to_sym])
      # We supply 0 in case of a subject without any jobs.
      job_count = subject_list.reduce(0) { |sum, subject| sum + counts_by_subject.fetch(subject, 0) }
      child_subjects_counts = VacancyCounter::GROUPED_SUBJECTS.fetch(subject.to_sym, []).filter_map { |child_subject|
        child_landing_page = CHILD_SUBJECTS_LIST[child_subject]
        next unless child_landing_page

        [child_landing_page, counts_by_subject.fetch(child_subject, 0)]
      }.to_h
      [landing_page, [job_count, child_subjects_counts]]
    end
  end

  def landing_page_fe_tallier(counts_by_subject)
    FE_SUBJECTS_LIST.to_h do |landing_page, subject|
      job_count = counts_by_subject.fetch(subject.to_sym, 0)
      [landing_page, [job_count, {}]]
    end
  end
end
