# When there are only two sorting options, these should be presented as links, not
# options in a drop-down. This component manages that display logic, among other things.
class SortComponent < ApplicationComponent
  attr_reader :url_params, :path, :sort

  # @param [Method] path The helper method which generates the destination path for the links or forms
  # @param [RecordSort, Object] sort An instance of a subclass of RecordSort or something implementing
  #                                  same interface as a RecordSort.
  # @param [Hash{Symbol => Object}] url_params Any necessary query parameters for the destination path
  def initialize(path:, sort:, url_params: {}, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    # TODO: Add an attribute to control whether the form uses form#submitListener (to decrease interdependency)
    @url_params = url_params
    @path = path
    @sort = sort
  end

  def render?
    sort.many?
  end

  def sort_form
    SortForm.new(sort.by)
  end

  private

  class SortForm
    include ActiveModel::Model

    attr_reader :sort_by

    def initialize(sort_by)
      @sort_by = sort_by
    end
  end

  def default_classes
    %w[sort-component]
  end
end
