class ValidatableSummaryListComponent::RowComponent < GovukComponent::SummaryListComponent::RowComponent
  def initialize(attribute, record:, error_path:, show_errors: true, classes: [], html_attributes: {}, **options)
    super(classes: classes, html_attributes: html_attributes)

    @attribute = attribute
    @record = record
    @error_path = error_path
    @options = options

    @errors = @record.errors.where(@attribute) if show_errors
  end

  attr_reader :attribute

  def before_render
    @translated_label = t("jobs.#{attribute}") unless @options[:label]
    @translated_text = t("jobs.not_defined")
  end

  def error_component
    ValidatableSummaryListComponent::ErrorComponent.new(
      errors: @errors,
      error_path: @error_path,
    )
  end

  def label
    @options[:label] || @translated_label
  end

  def build_text
    return @options[:text] if @options[:text]

    val = @record.public_send(@attribute)
    val = @options[:value_if_attribute_present] if val.present? && @options[:value_if_attribute_present].present?

    if @options[:optional]
      val.presence || @translated_text
    elsif boolean?
      val ? "Yes" : "No"
    else
      raw val
    end
  end

  def boolean?
    columns = case @record
              when BasePresenter
                @record.columns
              else
                @record.class.columns
              end

    columns.find { |c| c.name == @attribute.to_s }&.type == :boolean
  end
end
