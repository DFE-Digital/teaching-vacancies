class TermsAndConditionsForm
  include ActiveModel::Model

  attr_accessor :terms

  validates :terms, presence: true
  validates :terms, acceptance: { accept: "true" }
end
