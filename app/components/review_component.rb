# This is an abstract class.  See VacancyReviewComponent or
# JobApplicationReviewComponent for specific implementations.
class ReviewComponent < ApplicationComponent
  renders_one :header

  renders_one :above
  renders_one :below

  renders_one :sidebar, ReviewComponent::Sidebar

  def initialize(namespace:, show_tracks:, show_sidebar: true, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @namespace = namespace
    @show_tracks = show_tracks
    @show_sidebar = show_sidebar
  end

  def before_render
    return unless show_tracks?

    with_sidebar do
      render("#{namespace}/build/steps", track_assigns)
    end
  end

  def column_class
    show_sidebar? || show_tracks? ? %w[govuk-grid-column-two-thirds] : %w[govuk-grid-column-full]
  end

  private

  def default_classes
    %w[review-component]
  end

  attr_reader(*%I[
    namespace
  ])

  def show_tracks?
    !!@show_tracks
  end

  def show_sidebar?
    !!@show_sidebar
  end

  def track_assigns
    {}
  end
end
