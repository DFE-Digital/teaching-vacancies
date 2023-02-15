class NormaliseExistingOrganisationLogoDimensionsJob < ApplicationJob
  def perform
    Organisation.joins(:logo_attachment).each do |organisation|
      normalised_logo = ImageManipulator.new(image_file_path: organisation.logo.url).alter_dimensions_and_preserve_aspect_ratio("100", "100")

      organisation.logo.attach(io: StringIO.open(normalised_logo.to_blob), filename: organisation.logo.filename.to_s)
    end
  end
end
