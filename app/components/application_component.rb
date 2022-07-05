class ApplicationComponent < GovukComponent::Base
  attr_reader :classes

  def initialize(classes: [], html_attributes: {})
    # TODO: Workaround for GOV.UK Components changes - this doesn't exist anymore but we still rely
    #  on it.
    @classes = Array(classes)

    super(classes: classes, html_attributes: html_attributes)
  end

  private

  # TODO: Workaround for GOV.UK Components changes
  #  GOV.UK Components migrated from `default_classes` to `default_attributes`, this is a temporary
  #  fix until we decide whether to follow their new internal API or decouple ourselves from it.
  def default_attributes
    { class: default_classes }
  end

  def default_classes
    []
  end
end
