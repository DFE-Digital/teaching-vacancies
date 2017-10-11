class SchoolPresenter < BasePresenter

  def location
    [model.name, model.town, model.county].reject(&:blank?).join(', ')
  end

  def full_address
    [model.address, model.town, model.county, model.postcode].compact.join(', ')
  end
end
