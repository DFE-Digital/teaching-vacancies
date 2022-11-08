class SchoolsController < ApplicationController
  def index
    @school_search = Search::SchoolSearch.new(search_form.to_h, scope: search_scope)
    @pagy, @schools = pagy(@school_search.organisations)
  end

  private

  helper_method def search_form
    @search_form ||= SchoolSearchForm.new(params[:search]&.permit(SchoolSearchForm.attribute_names))
  end

  def search_scope
    Organisation.schools.or(Organisation.trusts).order(:name)
  end
end
