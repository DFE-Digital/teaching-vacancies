# Be sure to restart your server when you modify this file.

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
] + [
  /^age$/i,
]
