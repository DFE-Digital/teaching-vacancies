class JobPreferences < ApplicationRecord
  class JobScope
    def initialize(scope, job_preferences)
      @scope = scope
      @job_preferences = job_preferences
    end

    def call
      scope
        .where("phases <@ ARRAY[?]::int[]", Vacancy.phases.values_at(*job_preferences.phases))
        .then { |scope| apply_job_roles(scope) }
        .then { |scope| apply_key_stages(scope) }
        .then { |scope| apply_subjects(scope) }
        .where("working_patterns && ARRAY[?]::int[]", Vacancy.working_patterns.values_at(*job_preferences.working_patterns))
    end

    private

    attr_reader :scope, :job_preferences

    def apply_job_roles(scope)
      if @job_preferences.roles.any?
        scope.with_any_of_job_roles(@job_preferences.roles)
      else
        scope.where(job_roles: [])
      end
    end

    def apply_key_stages(scope)
      scope.where(key_stages: nil).or(
        scope.where("key_stages <@ ARRAY[?]::integer[]", Vacancy.key_stages.values_at(*job_preferences.key_stages)),
      )
    end

    def apply_subjects(scope)
      return scope unless job_preferences.subjects.any?

      scope.where("subjects && ARRAY[?]::varchar[]", job_preferences.subjects).or(
        scope.where(subjects: []),
      )
    end
  end
end
