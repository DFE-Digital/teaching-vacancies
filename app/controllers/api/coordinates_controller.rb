class Api::CoordinatesController < Api::ApplicationController
  def show
    render :json => {"test": location}
  end

  private

  def location
    params[:location]
  end
end