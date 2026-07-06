class VacancyCounter
  GROUPED_SUBJECTS = {
    "Dance, Drama and Music": %i[Dance Drama Music],
    "Economics and Business Studies": [:Economics, :"Business studies"],
    "English and Media Studies": [:English, :"Media studies"],
    "Foreign languages": %i[French Spanish German Mandarin Classics Welsh],
    "Health and Social Care": [:"Health and social care", :"Relationships and sex education"],
    "ICT and Computer Science": %i[ICT Computing],
    "Politics, Humanities and Social Sciences": [:Politics, :Humanities, :"Social sciences"],
    "Psychology, Sociology and RE": [:Psychology, :Philosophy, :Sociology, :"Religious education"],
    Science: %i[Biology Chemistry Physics],
  }.freeze

  class << self
    def role_counts(scope:)
      scope.joins("CROSS JOIN LATERAL unnest(job_roles) AS r(role)")
           .group("r.role")
           .count
           .transform_keys { |k| Vacancy::JOB_ROLES.invert.fetch(k).to_sym }
    end

    def phase_counts(scope:)
      scope.joins("CROSS JOIN LATERAL unnest(phases) AS p(phase)")
           .group("p.phase")
           .count
           .transform_keys { |k| Vacancy::PHASES.invert.fetch(k) }
    end

    def working_pattern_counts(scope:)
      scope.joins("CROSS JOIN LATERAL unnest(working_patterns) AS w(pattern)")
           .group("w.pattern")
           .count
           .transform_keys { |k| Vacancy::WORKING_PATTERNS_ENUM.invert.fetch(k) }
           .merge({ job_share: scope.where(is_job_share: true).count })
    end

    def subject_counts(scope:)
      scope.joins("CROSS JOIN LATERAL unnest(subjects) AS s(subject)")
           .group("s.subject")
           .count
           .symbolize_keys.tap do |hash|
        GROUPED_SUBJECTS.each do |group_name, subjects|
          hash[group_name] = hash.slice(*subjects + [group_name]).values.sum
        end
      end
    end
  end
end
