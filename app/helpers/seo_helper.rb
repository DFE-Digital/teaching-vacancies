module SeoHelper
  def seo_friendly_url(url)
    url.delete(".").gsub("%20", "-").tr("_", "-")
  end
end
