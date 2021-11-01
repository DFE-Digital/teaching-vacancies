module MapHelper
  def marker(lat, lng, data = {})
    return { lat: lat, lng: lng, data: data }
  end

  def polygon(text, href, **kwargs)
    govuk_button_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end
end