# Include this module in a ViewComponent when that component is deemed not to be
# mission-critical. Then a page containing that component will still be able to render,
# even if the non-critical component raised an error, rather than serving a 500 page.
module FailSafe
  def render_in(...)
    super
  rescue StandardError => e
    raise e unless Rails.env.production?

    Rollbar.error(e)
    nil
  end
end
