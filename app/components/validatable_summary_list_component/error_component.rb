class ValidatableSummaryListComponent::ErrorComponent < ViewComponent::Base
  def initialize(*, errors:, error_path:, **)
    super(*, **)

    @errors = errors
    @error_path = error_path
  end

  private

  attr_reader :errors, :error_path
end
