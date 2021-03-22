class TimelineComponent < GovukComponent::Base
  include ViewComponent::SlotableV2

  renders_one :heading, lambda { |title:|
    tag.h3(class: "timeline-component__heading govuk-heading-s") { title }
  }

  renders_many :items, lambda { |key:, value:|
    tag.li(class: "timeline-component__item") do
      safe_join([
        tag.h3(class: "timeline-component__key govuk-heading-s") { key },
        tag.p(class: "timeline-component__value govuk-body") { value },
      ])
    end
  }

  private

  def default_classes
    %w[timeline-component]
  end
end
