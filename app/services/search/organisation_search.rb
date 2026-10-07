# frozen_string_literal: true

module Search
  class OrganisationSearch
    extend Forwardable

    def_delegators :location_search, :point_coordinates, :polygon

    attr_reader :search_criteria, :location, :radius

    def initialize(search_criteria, scope:)
      @search_criteria = search_criteria
      @name = search_criteria[:name]
      @location = search_criteria[:location]
      @radius = search_criteria[:radius]
      @scope = scope
    end

    def active_criteria
      search_criteria
        .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
    end

    def location_search
      @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius])
    end

    def organisations
      @organisations ||= scope
    end

    def total_count
      @total_count ||= organisations.count
    end

    def scope_without_location
      scope = @scope.all

      scope = scope.search_by_name(@name) if @name.present?
      scope = scope.with_live_vacancies if @search_criteria.key?(:job_availability)

      scope
    end

    private

    def scope
      scope = scope_without_location

      scope = scope.search_by_location(location, radius, polygon:) if location

      scope
    end
  end
end
