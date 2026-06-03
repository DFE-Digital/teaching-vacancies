module LandingPagesHelper
  def landing_page_link_or_text(landing_page_criteria, text, match: :exact)
    lp = match == :exact ? LandingPage.matching(landing_page_criteria) : LandingPage.partially_matching(landing_page_criteria)
    return tag.span { text } unless lp

    text = match == :exact ? lp.name : landing_page_criteria.values.flatten.first
    link_text = t("landing_pages.accessible_link_text_html", name: text)
    govuk_link_to(link_text, landing_page_path(lp.slug), text_colour: true)
  end

  def linked_locations(vacancy)
    vacancy.location.last(2).map(&:parameterize).filter_map do |location|
      location = REDIRECTED_LOCATION_LANDING_PAGES[location] || location

      next unless location && LocationLandingPage.exists?(location)

      govuk_link_to(LocationLandingPage[location].name, location_landing_page_path(LocationLandingPage[location].location))
    end
  end

  def linked_job_roles_and_ect_status(vacancy)
    tag.ul class: "govuk-list" do
      safe_join(
        vacancy.job_roles.map { |role| tag.li(linked_job_role(I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{role}"))) }
                         .push(tag.li(linked_ect_status(vacancy))),
      )
    end
  end

  def linked_job_role(role)
    landing_page_link_or_text({ job_roles: [role] }, role)
  end

  def linked_ect_status(vacancy)
    return unless vacancy.job_roles.include?("teacher") && vacancy.ect_suitable?

    landing_page_link_or_text({ ect_statuses: [vacancy.ect_status] }, vacancy.ect_status.humanize)
  end

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

  FE_PHASES_LIST = { "sixth-form-or-college-jobs" => "sixth_form_or_college" }.freeze

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

  SUBJECTS_COLUMNS = [
    %w[maths-teacher-jobs english-media-studies-teacher-jobs physical-education-teacher-jobs dance-drama-music-teacher-jobs science-teacher-jobs],
    %w[history-teacher-jobs geography-teacher-jobs mfl-teacher-jobs],
    %w[ict-computer-science-teacher-jobs economics-business-studies-teacher-jobs art-design-technology-teacher-jobs food-technology-teacher-jobs politics-humanities-social-sciences-teacher-jobs psychology-philosophy-sociology-re-teacher-jobs health-relationships-social-care-teacher-jobs],
  ].freeze

  SUBJECTS_LIST = {
    "art-design-technology-teacher-jobs" => "Art and Design Technology",
    "dance-drama-music-teacher-jobs" => "Dance, Drama and Music",
    "economics-business-studies-teacher-jobs" => "Economics and Business Studies",
    "english-media-studies-teacher-jobs" => "English and Media Studies",
    "food-technology-teacher-jobs" => "Food technology",
    "geography-teacher-jobs" => "Geography",
    "health-relationships-social-care-teacher-jobs" => "Health and Social Care",
    "history-teacher-jobs" => "History",
    "ict-computer-science-teacher-jobs" => "ICT and Computer Science",
    "maths-teacher-jobs" => "Mathematics",
    "mfl-teacher-jobs" => "Foreign Languages",
    "physical-education-teacher-jobs" => "Physical education",
    "politics-humanities-social-sciences-teacher-jobs" => "Politics, Humanities and Social Sciences",
    "psychology-philosophy-sociology-re-teacher-jobs" => "Psychology, Sociology and RE",
    "science-teacher-jobs" => "Science",
  }.freeze

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

  def landing_page_teaching_roles_list = TEACHING_ROLES_LIST
  def landing_page_support_roles_list = SUPPORT_ROLES_LIST
  def landing_page_phases_list = PHASES_LIST
  def landing_page_working_patterns_list = WORKING_PATTERNS_LIST
  def landing_page_fe_phases_list = FE_PHASES_LIST
  def landing_page_fe_teaching_roles_list = FE_TEACHING_ROLES_LIST
  def landing_page_fe_support_roles_list = FE_SUPPORT_ROLES_LIST
  def landing_page_subjects_columns = SUBJECTS_COLUMNS
  def landing_page_subjects_list = SUBJECTS_LIST
  def child_subjects_list = CHILD_SUBJECTS_LIST

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

  FE_SUBJECTS_LIST = {
    "accountancy-and-finance-fe-jobs" => "Accountancy and finance",
    "agriculture-horticulture-land-based-studies-fe-jobs" => "Agriculture/horticulture/land based studies",
    "animal-care-fe-jobs" => "Animal care",
    "art-and-design-fe-jobs" => "Art and design",
    "biology-fe-jobs" => "Biology",
    "british-sign-language-fe-jobs" => "British sign language",
    "building-and-construction-fe-jobs" => "Building and construction",
    "catering-fe-jobs" => "Catering",
    "chemistry-fe-jobs" => "Chemistry",
    "childrens-development-and-learning-fe-jobs" => "Children's development and learning",
    "classics-fe-jobs" => "Classics",
    "computer-science-fe-jobs" => "Computer science",
    "construction-fe-jobs" => "Construction",
    "counselling-fe-jobs" => "Counselling",
    "customer-service-fe-jobs" => "Customer service",
    "dance-drama-and-music-fe-jobs" => "Dance drama and music",
    "design-and-technology-fe-jobs" => "Design and technology",
    "early-years-fe-jobs" => "Early years",
    "economics-and-business-studies-fe-jobs" => "Economics and Business Studies",
    "electrics-fe-jobs" => "Electrics",
    "engineering-fe-jobs" => "Engineering",
    "english-and-media-studies-fe-jobs" => "English and Media Studies",
    "english-as-a-foreign-language-fe-jobs" => "English as a foreign language",
    "fabrication-and-welding-fe-jobs" => "Fabrication and welding",
    "farming-fe-jobs" => "Farming",
    "fashion-fe-jobs" => "Fashion",
    "food-technology-fe-jobs" => "Food technology",
    "foreign-languages-fe-jobs" => "Foreign languages",
    "french-fe-jobs" => "French",
    "functional-skills-fe-jobs" => "Functional skills",
    "games-design-fe-jobs" => "Games design",
    "geography-fe-jobs" => "Geography",
    "german-fe-jobs" => "German",
    "graphic-design-fe-jobs" => "Graphic design",
    "hair-and-beauty-fe-jobs" => "Hair and beauty",
    "health-and-social-care-fe-jobs" => "Health and Social Care",
    "history-fe-jobs" => "History",
    "hotel-catering-and-travel-fe-jobs" => "Hotel catering and travel",
    "humanities-fe-jobs" => "Humanities",
    "ict-and-computer-science-fe-jobs" => "ICT and Computer Science",
    "land-and-property-management-fe-jobs" => "Land and Property Management",
    "leadership-and-management-fe-jobs" => "Leadership and management",
    "logistics-fe-jobs" => "Logistics",
    "mandarin-fe-jobs" => "Mandarin",
    "maths-fe-jobs" => "Maths",
    "modern-foreign-languages-fe-jobs" => "Modern foreign languages",
    "motor-vehicle-fe-jobs" => "Motor vehicle",
    "music-fe-jobs" => "Music",
    "people-management-fe-jobs" => "People management",
    "philosophy-fe-jobs" => "Philosophy",
    "photography-fe-jobs" => "Photography",
    "physical-education-fe-jobs" => "Physical Education",
    "physics-fe-jobs" => "Physics",
    "plumbing-and-heating-fe-jobs" => "Plumbing and heating",
    "politics-fe-jobs" => "Politics",
    "pshe-fe-jobs" => "PSHE",
    "psychology-fe-jobs" => "Psychology",
    "public-services-fe-jobs" => "Public services",
    "religious-education-fe-jobs" => "Religious education",
    "science-fe-jobs" => "Science",
    "send-fe-jobs" => "SEND",
    "sociology-fe-jobs" => "Sociology",
    "spanish-fe-jobs" => "Spanish",
    "sport-and-leisure-fe-jobs" => "Sport and leisure",
    "sports-science-fe-jobs" => "Sports science",
    "tourism-fe-jobs" => "Tourism",
    "welsh-fe-jobs" => "Welsh",
    "woodworking-joinery-and-carpentry-fe-jobs" => "Woodworking joinery and carpentry",
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

  def landing_page_fe_subjects_list
    FE_SUBJECTS_LIST
  end

  def landing_page_fe_subjects_columns
    FE_SUBJECTS_COLUMNS
  end

  def landing_page_fe_tallier(counts_by_subject)
    FE_SUBJECTS_LIST.to_h do |landing_page, subject|
      job_count = counts_by_subject.fetch(subject.to_sym, 0)
      [landing_page, [job_count, {}]]
    end
  end
end
