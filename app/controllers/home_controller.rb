class HomeController < ApplicationController
  def index
    @form = Jobseekers::SearchForm.new
  end

  private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
