class OrganisationForm
  include ActiveModel::Model

  attr_accessor :description, :website

  validates :website, url: { allow_blank: true }

  def initialize(params = {})
    @description = params[:description]
    @website = params[:website]
  end
end
