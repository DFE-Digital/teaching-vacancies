# This is an abstract class.  See VacancyReviewComponent or
# JobApplicationReviewComponent for specific implementations.
class ReviewComponent < ApplicationComponent
  renders_one :header

  renders_one :above
  renders_one :below

  renders_one :sidebar, ReviewComponent::Sidebar

  def initialize(namespace:, show_tracks:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @namespace = namespace
    @show_tracks = show_tracks
  end

  def before_render
    return unless show_tracks?

    sidebar do
      render("#{namespace}/build/steps", track_assigns)
    end
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
