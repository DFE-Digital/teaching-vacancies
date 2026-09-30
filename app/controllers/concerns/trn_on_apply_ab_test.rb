# The "trn_on_apply" A/B test asks some jobseekers for their teacher reference number before they apply.
# It can only run for signed-in jobseekers, and only for teaching and middle leader roles.
module TrnOnApplyAbTest
  extend ActiveSupport::Concern

  private

  def trn_prompt_required?(vacancy)
    jobseeker_signed_in? && vacancy.teaching_or_middle_leader_role? && field_test(:trn_on_apply) == "trn"
  end
end
