# Be sure to restart your server when you modify this file.
MAILER_SANITIZED_PARAMS = %w[
  mailer.subject
  mailer.to
].freeze

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  email
  password
  national_insurance_number
  disability
  ethnicity
  gender
  orientation
  religion
  id
  job_title
  jobseeker_id
  jobseeker_profile_id
  support_needed_details
  rejection_reasons
  further_instructions
  job_application_id
  publisher_id
  first_name
  last_name
  previous_names
  street_address
  city
  postcode
  phone_number
  institution
  organisation
  recipient_id
  oid
  main_duties
  teacher_reference_number
  finished_studying_details
  close_relationships_details
  gaps_in_employment_details
  personal_statement
  unconfirmed_email
  family_name
  given_name
  email_address
  about_you
  name
  application_email
  contact_email
  contact_number
  qualification_results_attributes
  govuk_one_login_id
  religious_reference_type
  religious_referee_name
  religious_referee_address
  religious_referee_role
  religious_referee_email
  religious_referee_phone
  ethos_and_aims
  baptism_address
  baptism_date
  faith
  place_of_worship
  country
  address_line_1
  address_line_2
  date_of_birth
  has_unspent_convictions
  has_spent_convictions
  is_barred
  has_been_refered
  is_known_to_children_services
  has_been_dismissed
  has_been_disciplined
  has_been_disciplined_by_regulatory_body
  agreed_for_processing
  agreed_for_criminal_record
  agreed_for_organisation_update
  agreed_for_information_sharing
] + [
  /^age$/i,
]

Rails.application.config.filter_parameters += MAILER_SANITIZED_PARAMS
