class CampaignPage
  attr_reader :utm_content_code, :criteria, :banner_image, :hidden_filters

  # Language subjects need to be uppercase.
  LANGUAGE_SUBJECTS = %w[English Spanish German French].freeze

  def self.exists?(utm_content)
    return false if utm_content.blank?

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

  def banner_title(name, subject = nil, phase = nil)
    subject = subject&.downcase unless LANGUAGE_SUBJECTS.include?(subject)
    title = I18n.t("campaign_pages.#{utm_content_code}.banner_title", name: name, subject: subject, phase: phase)
    title.squeeze(" ").strip
  end
end
