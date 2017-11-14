class SchoolsController < ApplicationController
  def index
    # Nothing to do here yet
  end

  def search
    @schools = School.where(['name ILIKE ?', "%#{params[:name]}%"])
    render 'search_results'
  end
end