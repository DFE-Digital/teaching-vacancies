require "rails_helper"
require "swagger_helper"

# This spec guards the V1 API contract against silent breakage caused by changes to Vacancy model constants.
#
# The ATS API V1 schema defines a fixed set of allowed enum values for fields like phases, key_stages, etc.
# These are stored as frozen constants (V1_PHASES, V1_KEY_STAGES, ...) in swagger_helper.rb, deliberately
# decoupled from the Vacancy model constants. This decoupling means a model change does NOT automatically
# change the API contract — which is correct, because the API is a published, versioned interface.
#
# This spec detects when the model drifts from the V1 contract, forcing a conscious decision:
#
#   Scenario A — a new value is added to the model (e.g., Vacancy::PHASES gains :alternative_provision):
#     - This is non-breaking: consumers only get back values they themselves submitted, so a new model
#       value will never appear in their responses unless they explicitly use it.
#     - Update the frozen V1 constant (e.g., V1_PHASES) to include the new value and regenerate swagger.yaml.
#
#   Scenario B — a value is removed or renamed in the model (e.g., :secondary split into :lower_secondary + :upper_secondary):
#     - The V1 schema must keep accepting the old value ("secondary") from API consumers.
#     - Add an inbound mapping in the service layer to translate "secondary" to the appropriate new model value(s).
#     - Add an outbound mapping to translate new model values back to "secondary" in API responses.
#
#   Scenario C — mappings become untenable (too many, or semantics have fundamentally changed):
#     - Create V2 of the API with a schema that reflects the new model.
#     - Deprecate V1 with a communicated timeline.
#     - Do NOT update V1 frozen constants.
RSpec.describe "V1 API schema enum consistency" do
  {
    "job_roles" => { v1: V1_JOB_ROLES, model: -> { Vacancy.job_roles.keys } },
    "contract_types" => { v1: V1_CONTRACT_TYPES, model: -> { Vacancy.contract_types.keys } },
    "working_patterns" => { v1: V1_WORKING_PATTERNS, model: -> { Vacancy::WORKING_PATTERNS } },
    "phases" => { v1: V1_PHASES, model: -> { Vacancy.phases.keys } },
    "key_stages" => { v1: V1_KEY_STAGES, model: -> { Vacancy.key_stages.keys } },
    "subjects" => { v1: V1_SUBJECTS, model: -> { SUBJECT_OPTIONS.map(&:first) } },
  }.each do |field, sources|
    describe field do
      let(:v1_values) { sources[:v1].map(&:to_s).sort }
      let(:model_values) { sources[:model].call.map(&:to_s).sort }

      it "V1 schema matches current model values" do
        added = model_values - v1_values
        removed = v1_values - model_values

        divergences = []
        divergences << "Added in model but missing from V1 schema: #{added}" if added.any?
        divergences << "Removed from model but still in V1 schema: #{removed}" if removed.any?

        failure_message = "V1 API enum for '#{field}' has diverged from the model. Do NOT just update the frozen V1 constant.\n" \
                          "Read the comment at the top of this spec file for the correct remediation steps.\n" \
                          "#{divergences.join("\n")}"
        expect(divergences).to be_empty, failure_message
      end
    end
  end
end
