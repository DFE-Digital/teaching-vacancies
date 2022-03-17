class SearchableCollectionComponentPreview < Base
  def self.options
    Array(0..10).map { |i| ["Label #{i + 1}", "Hint #{i + 1}"] }
  end

  def self.component_class
    SearchableCollectionComponent
  end
end
