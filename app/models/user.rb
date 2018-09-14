class User < ApplicationRecord
  include Auditor::Model

  def accepted_terms_and_conditions?
    accepted_terms_at.present?
  end
end
