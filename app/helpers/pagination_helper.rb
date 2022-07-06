module PaginationHelper
  include Pagy::Frontend

  # Custom replacement for `#pagy_info` with "our" style of results presentation
  def pagy_stats(pagy, type: "result")
    I18n.t(
      "app.pagy_stats_html",
      from: pagy.from,
      to: pagy.to,
      total: pagy.count,
      type: type.pluralize(pagy.count),
    ).html_safe
  end
end
