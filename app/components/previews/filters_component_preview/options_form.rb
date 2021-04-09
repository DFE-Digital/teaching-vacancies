class FiltersComponentPreview::OptionsForm
  include ActiveModel::Model

  attr_reader :remove_buttons, :close_all, :search, :scroll, :small, :options

  def initialize(params = {})
    preview_criteria = if params[:filters_component_preview_options_form].present?
                         JSON.parse(params[:filters_component_preview_options_form].to_json).symbolize_keys
                       else
                         {}
                       end

    # options
    @remove_buttons = preview_criteria[:remove_buttons].present? ? preview_criteria[:remove_buttons].first : false
    @close_all = preview_criteria[:close_all].present? ? preview_criteria[:close_all].first : false

    # # item
    @search = preview_criteria[:search].present? ? preview_criteria[:search].first : false
    @scroll = preview_criteria[:scroll].present? ? preview_criteria[:scroll].first : false

    # formbuilder
    @small = preview_criteria[:small].present? ? preview_criteria[:small].first : false
  end
end
