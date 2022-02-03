class Jobseekers::JobApplication::ReferencesForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.optional?
    false
  end
end
