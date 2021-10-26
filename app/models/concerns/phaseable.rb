module Phaseable
  extend ActiveSupport::Concern

  included do
    before_save :update_readable_phases
  end

  def allow_phase_to_be_set?
    central_office? || organisation_phases.many? || organisation_phases.none?
  end

  def one_phase?
    # Check that the number of phases isn't zero or more than one.
    # A few dozen organisations have a phase of 'not_applicable' and hence an empty 'readable_phases' attribute,
    # resulting in vacancy.education_phases.count likewise being zero. Treat vacancies of unknown phase in the same way
    # as vacancies of multiple phases, including allowing the user to select a phase in the education_phases step.
    phase != "multiple_phases" && education_phases.one?
  end

  def education_phases
    return organisation_phases if phase == "multiple_phases" || phase.blank?

    [phase]
  end

  def update_readable_phases
    self.readable_phases = education_phases
  end

  def organisation_phases
    organisations.map(&:readable_phases).flatten.uniq.compact
  end
end
