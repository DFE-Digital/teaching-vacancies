class MapComponentPreview < Base
  def self.options
    Vacancy.first
  end

  def self.component_class
    MapComponent
  end
end
