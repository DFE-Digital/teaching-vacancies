class Publishers::Organisation::PhotoForm < BaseForm
  validates :photo, presence: true
  validates :photo, form_file: true

  attr_accessor :photo

  def file_type
    :image
  end

  def content_types_allowed
    %w[image/jpeg image/png].freeze
  end

  def file_size_limit
    5.megabytes
  end

  def valid_file_types
    %i[JPG JPEG PNG]
  end
end
