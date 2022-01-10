# This is an abstract class.  See VacancyReviewComponent or
# JobApplicationReviewComponent for specific implementations.
class ReviewComponent < GovukComponent::Base
  renders_one :header

  renders_one :above
  renders_one :below

  def initialize(namespace:, show_tracks:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @namespace = namespace
    @show_tracks = show_tracks
  end

  private

  attr_reader(*%I[
    namespace
  ])

  def show_tracks?
    !!@show_tracks
  end

  def track_assigns
    {}
  end
end
