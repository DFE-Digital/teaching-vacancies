class Publishers::AtsInterstitialsController < Publishers::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show]

  def show
    @religious_character = @school.ats_religious_variant
  end
end
