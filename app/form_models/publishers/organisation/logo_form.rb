class Publishers::Organisation::LogoForm < Publishers::Organisation::ImageUploadBaseForm
  validate :valid_organisation_logo

  attr_accessor :logo

  def valid_organisation_logo
    @valid_organisation_logo ||= logo if valid_image_dimensions?(logo) && valid_file_size?(logo) && valid_file_type?(logo) && virus_free?(logo)
  end

  private

  def file_upload_field_name
    :logo
  end
end
