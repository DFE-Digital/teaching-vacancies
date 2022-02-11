class HomeController < ApplicationController
  include ReturnPathTracking::Helpers

  def index
    @form = Jobseekers::SearchForm.new
    @vacancy_facets = VacancyFacets.new
  end

  def jobseeker_forced_login
    forced_login(:jobseeker)
  end

  def publisher_forced_login
    forced_login(:publisher)
  end

  def jobseeker_failed_login
    failed_login(:jobseeker)
  end

  def publisher_failed_login
    failed_login(:jobseeker)
  end

  private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end

  def forced_login(scope)
    if attempted_path
      store_return_location(attempted_path, scope: scope)
    end

    params_hash = {
      redirected: true,
    }

    params_hash[:login_failure] = login_failure if login_failure

    redirect_to send("new_#{scope}_session_path", params_hash)
  end

  def failed_login(scope)
    redirect_to send("new_#{scope}_session_path", login_failure: login_failure)
  end

  def attempted_path
    request.env.dig("warden.options", :attempted_path)
  end

  def login_failure
    return :timeout if flash[:timedout]

    request.env.dig("warden.options", :message)
  end
end
