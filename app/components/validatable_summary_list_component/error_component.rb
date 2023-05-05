class ValidatableSummaryListComponent::ErrorComponent < ViewComponent::Base
  def initialize(*args, errors:, error_path:, **kwargs)
    super(*args, **kwargs)

    @errors = errors
    @error_path = error_path
  end

  private

  attr_reader :errors, :error_path
end
