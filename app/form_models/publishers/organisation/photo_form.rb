class Publishers::Organisation::PhotoForm < BaseForm
  validates :photo, presence: true
  validates :photo, form_file: IMAGE_VALIDATION_OPTIONS.merge(skip_google_drive_virus_check: true)

  attr_accessor :photo
end
