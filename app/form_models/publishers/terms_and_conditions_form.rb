class Publishers::TermsAndConditionsForm < BaseForm
  attr_accessor :terms

  validates :terms, presence: true
  validates :terms, acceptance: { accept: "true" }
end
