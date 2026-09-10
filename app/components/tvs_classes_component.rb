class TvsClassesComponent < ApplicationComponent
  attr_reader :classes

  def initialize(classes: [], html_attributes: {})
    # Workaround for GOV.UK Components changes - this doesn't exist anymore but we still rely
    #  on it in a couple of places. Mostly we shouldn't, as our components shouldn't be stylable
    # (but govuk library components need to be because they should not be opened)
    @classes = Array(classes)
    super
  end
end
