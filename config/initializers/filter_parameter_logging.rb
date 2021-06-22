# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  email
  password

  national_insurance_number

  age
  disability
  ethnicity
  ethnicity_description
  gender
  gender_description
  orientation
  orientation_description
  religion
  religion_description
]
