class ImageManipulator
  def initialize(image_file_path:)
    @image_file_path = image_file_path
  end

  def alter_dimensions_and_preserve_aspect_ratio(width, height)
    MiniMagick::Image.open(@image_file_path).tap do |image|
      image.resize "#{width}x#{height}"
      image.close
    end
  end
end
