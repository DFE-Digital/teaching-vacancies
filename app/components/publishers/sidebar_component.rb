class Publishers::SidebarComponent < ViewComponent::Base
  delegate :set_active_step_class, to: :helpers
  delegate :set_visited_step_class, to: :helpers
  delegate :steps_to_display, to: :helpers

  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def render?
    @vacancy.blank? || %w[create review].include?(@vacancy.state)
  end
end
