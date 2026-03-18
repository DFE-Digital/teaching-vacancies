# frozen_string_literal: true

module KeyStagesChecks
  PHASES_TO_KEY_STAGES_MAPPINGS = {
    nursery: %i[early_years],
    primary: %i[early_years ks1 ks2],
    secondary: %i[ks3 ks4 ks5],
    sixth_form_or_college: %i[ks5],
    through: %i[early_years ks1 ks2 ks3 ks4 ks5],
  }.freeze

  def key_stages_for_phases
    phases.map { |phase| PHASES_TO_KEY_STAGES_MAPPINGS[phase.to_sym] }.flatten.uniq.sort
  end
end
