class SupportUsers::ServiceData::FeCollegesWithoutPublishersController < SupportUsers::ServiceData::BaseController
  def index
    @colleges = School.kept.colleges.where(updated_at: 1.week.ago..).without_publishers_accepted_terms.order(:name)
  end
end
