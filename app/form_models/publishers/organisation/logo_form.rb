class Publishers::Organisation::LogoForm < BaseForm
  validates :logo, presence: true
  validates :logo, form_file: IMAGE_VALIDATION_OPTIONS.merge(skip_google_drive_virus_check: true)

  attr_accessor :logo
end
