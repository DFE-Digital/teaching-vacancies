class CampaignPage
  attr_reader :utm_content_code, :criteria, :banner_image, :hidden_filters

  def self.exists?(utm_content)
    Rails.application.config.campaign_pages.key?(utm_content.to_sym)
  end

  def self.[](utm_content_code)
    raise "No such campaign page: '#{utm_content_code}'" unless exists?(utm_content_code)

    criteria = Rails.application.config.campaign_pages[utm_content_code.to_sym].except(:banner_image)
    new(utm_content_code, criteria)
  end

  def initialize(utm_content_code, criteria)
    @utm_content_code = utm_content_code.to_s
    @banner_image = Rails.application.config.campaign_pages[utm_content_code.to_sym][:banner_image]
    @criteria = criteria
    @hidden_filters = criteria[:hidden_filters] || []
  end

  def banner_title(name, subject = nil)
    I18n.t("campaign_pages.#{utm_content_code}.banner_title", name: name, subject: subject)
  end
end