class Publishers::Organisation::PhotoForm < BaseForm
  validates :photo, presence: true
  validates :photo, form_file: IMAGE_VALIDATION_OPTIONS

  attr_accessor :photo
end
