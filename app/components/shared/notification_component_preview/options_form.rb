class Shared::NotificationComponentPreview::OptionsForm
  include ActiveModel::Model

  attr_reader :background, :dismiss, :title, :body, :variant, :icon

  def initialize(params = {})
    preview_criteria = if params[:shared_notification_component_preview_options_form].present?
                         JSON.parse(params[:shared_notification_component_preview_options_form].to_json).symbolize_keys
                       else
                         {}
                       end

    @icon = preview_criteria[:icon] || false
    @background = preview_criteria[:background] || false
    @dismiss = preview_criteria[:dismiss] || false
    @title = preview_criteria[:title] || "title text"
    @body = preview_criteria[:body] || "body text"
    @variant = preview_criteria[:variant] || "success"
  end
end
