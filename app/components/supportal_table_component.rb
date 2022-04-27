class SupportalTableComponent < GovukComponent::Base
  SUPPORTED_TYPES = %i[
    boolean
    column
    datetime
    string
    tags
    text
  ].freeze

  TAG_COLOURS = { "jobseeker" => "blue", "hiring staff" => "green", "unknown" => "red" }.freeze

  def initialize(entries:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @entries = entries
    @columns = []
  end

  SUPPORTED_TYPES.each do |type|
    define_method(type) do |*args, &block|
      column(*args, type: type, &block)
    end
  end

  def column(header, method_name = nil, type: nil, &block)
    value_block = (block || ->(entry) { entry.public_send(method_name) })

    @columns << [header, Formatter.new(value_block, type, self), type]
  end

  def before_render
    content # Execute the component block
  end

  def govuk_tags(array)
    tag.ul(class: "govuk-list tags-list") do
      Array(array).compact.each do |text|
        concat(tag.li { govuk_tag(text: text.humanize, colour: TAG_COLOURS[text]) })
      end
    end
  end

  private

  class Formatter
    def initialize(value_block, type, component)
      @value_block = value_block
      @type = type
      @component = component
    end

    def call(entry)
      case @type
      when :boolean
        case @value_block.call(entry)
        when true
          "Yes"
        when false
          "No"
        end
      when :tags
        @component.govuk_tags(@value_block.call(entry))
      else
        @value_block.call(entry)
      end
    end
  end

  def default_classes
    %w[supportal-table-component]
  end
end
