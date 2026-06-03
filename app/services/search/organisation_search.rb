# frozen_string_literal: true

module Search
  class OrganisationSearch
    extend Forwardable

    def_delegators :location_search, :point_coordinates, :polygon

    attr_reader :search_criteria, :location, :radius, :original_scope

    def initialize(search_criteria, scope:)
      @search_criteria = search_criteria
      @name = search_criteria[:name]
      @location = search_criteria[:location]
      @radius = search_criteria[:radius]
      @original_scope = scope.where(scope.where_values_hash)
      @scope = scope
    end

    def active_criteria
      search_criteria
        .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
    end

    def location_search
      @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius])
    end

    def wider_search_suggestions
      @wider_search_suggestions ||= Search::WiderSuggestionsBuilder.call(self)
    end

    def organisations
      @organisations ||= scope
    end

    def total_count
      @total_count ||= organisations.count
    end

    private

    def scope
      scope = @scope.all

      scope = scope.search_by_name(@name) if @name.present?
      scope = scope.search_by_location(location, radius, polygon:) if location
      scope = scope.with_live_vacancies if @search_criteria.key?(:job_availability)

      scope
    end
  end
end
