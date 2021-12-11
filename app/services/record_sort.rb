## A class encapsulating sorting behaviour, including:
# - Knowing which sorting options are available and when
# - Knowing which option to default to and when
# - Tracking which option is currently selected
# - Updating that option based on a new selection
#
# A given use of the AccessibleSortComponent should subclass RecordSort for its purpose (`sort` param).
# A child class' name should be of the form <RelationName>Sort, e.g. UserSort.
#
# Child classes must implement an #options method defining the sorting options, which
# should be an array of `SortOption`s.
class RecordSort
  include Enumerable
  attr_reader :sort_by, :order

  delegate :each, to: :options

  def initialize(...)
    @sort_by = default_sort_option.by
    @order = default_sort_option.order
  end

  # Overwrite this in the subclass if any logic is needed to set the default sorting option
  def default_sort_option
    @default_sort_option ||= options.first
  end

  # Update @sort_by and @order attributes. These are used to track which sorting option is currently active.
  def update(sort_by:)
    option = if options.map(&:by).include?(sort_by)
               options.detect { |opt| opt.by == sort_by }
             else
               default_sort_option
             end

    @sort_by = option.by
    @order = option.order

    self
  end

  def by_db_column?
    # JobApplication.last_name is a virtual attribute
    # Search::VacancySort allows sorting by 'relevance' which is neither a db column nor a virtual attribute
    sort_by.in?(record_class.column_names)
  end

  alias by sort_by

  private

  SortOption = Struct.new(:by, :display_name, :order)

  def record_class
    self.class.name.split("::").last.gsub("Sort", "").constantize
  end
end
