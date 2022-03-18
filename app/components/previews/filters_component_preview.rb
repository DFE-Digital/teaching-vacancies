class FiltersComponentPreview < Base
  def self.options
    [
      {
        legend: "filter group",
        key: "preview_group_1",
        selected: %w[option_1 option_2],
        options: [%w[option_1 option1], %w[option_2 option2]],
        value_method: :first,
        selected_method: :last,
      },
      {
        legend: "filter group",
        key: "preview_group_2",
        selected: %w[option_1 option_2],
        options: [%w[option_1 option1], %w[option_2 option2]],
        value_method: :first,
        selected_method: :last,
      },
    ]
  end

  def self.component_class
    FiltersComponent
  end
end
