class JobPreferences < ApplicationRecord
  class JobScope
    # TODO: Delete mapping once there are no more vacancies using "senior_leader" and "middle_leader" roles.
    ROLE_MAPPINGS = {
      "senior_leader" => %w[headteacher headteacher_deputy headteacher_assistant],
      "middle_leader" => %w[head_of_year head_of_department],
    }.freeze

    def initialize(scope, job_preferences)
      @scope = scope
      @job_preferences = job_preferences
    end

    def call
      scope
      .where(job_role: roles)
        .where("phases <@ ARRAY[?]::int[]", Vacancy.phases.values_at(*job_preferences.phases))
        .then { |scope| apply_key_stages(scope) }
        .then { |scope| apply_subjects(scope) }
        .where("working_patterns && ARRAY[?]::int[]", Vacancy.working_patterns.values_at(*job_preferences.working_patterns))
    end

    private

    attr_reader :scope, :job_preferences

    # TODO: Delete whole mapping and directly query by "job_preference.roles" once there are no more vacancies using
    # "senior_leader" and "middle_leader" roles.
    #
    # Vacancies at the moment still use the generic "senior_leader" and "middle_leader" roles.
    # Jobseeker preferences split those roles into more granular roles:
    # - "headteacher" => "headteacher", "headteacher_deputy", "headteacher_assistant"
    # - "middle_leader" => "head_of_year", "head_of_department"
    #
    # This method ensures that vacancies using the old generic roles are matched with jobseekers with granular roles
    #
    # If any of the granular roles is present in the Jobseeker preferences, we add the generic role in the vacancy search.
    #
    # EG:
    # - Jobseeker role preferences: ["headteacher", "headteacher_assistant"]
    # - Method output: ["headteacher", "headteacher_assistant", "senior_leader"]
    # - Vacancies with role "senior_leader" will be returned.
    # - When vacancies are migrated to the new granular roles, vacancies wih roles "headteacher" and/or "headteacher_assistant"
    #   will be returned.
    def roles
      job_preferences.roles.tap do |roles|
        ROLE_MAPPINGS.each { |generic_role, granular_roles| roles << generic_role if granular_roles.intersect?(roles) }
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
