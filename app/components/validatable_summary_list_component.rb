class ValidatableSummaryListComponent < GovukComponent::SummaryListComponent
  registered_slots.delete(:rows)

  renders_many :rows, (lambda do |*args, **kwargs|
    ValidatableSummaryListComponent::RowComponent.new(
      *args,
      record: @record,
      show_errors: @show_errors,
      error_path: @error_path,
      **kwargs,
    )
  end)

  def initialize(record, error_path:, show_errors: true, **kwargs)
    super(**kwargs)

    @record = record
    @show_errors = show_errors
    @error_path = error_path
  end
end
