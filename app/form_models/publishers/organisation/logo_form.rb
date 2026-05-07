class Publishers::Organisation::LogoForm < BaseForm
  validates :logo, presence: true
  validates :logo, form_file: IMAGE_VALIDATION_OPTIONS

  attr_accessor :logo
end
