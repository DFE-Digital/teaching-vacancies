class SchoolsController < ApplicationController
  def index
    # TODO: Use school search service
    @schools_search = Organisation.all
    @pagy, @schools = pagy(@schools_search)
  end
end
