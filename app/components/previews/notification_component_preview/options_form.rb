class Previews::NotificationComponentPreview::OptionsForm
  include ActiveModel::Model

  attr_reader :background, :dismiss, :icon

  def initialize(params = {})
    preview_criteria = if params[:previews_notification_component_preview_options_form].present?
                         JSON.parse(params[:previews_notification_component_preview_options_form].to_json).symbolize_keys
                       else
                         {}
                       end

    @icon = preview_criteria[:icon].present? ? preview_criteria[:icon].first : false
    @background = preview_criteria[:background].present? ? preview_criteria[:background].first : false
    @dismiss = preview_criteria[:dismiss].present? ? preview_criteria[:dismiss].first : false
  end
end
