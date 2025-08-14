class Conversation < ApplicationRecord
  belongs_to :job_application
  has_many :messages, dependent: :destroy

  def self.default_title_for(job_application)
    "Regarding application: #{job_application.vacancy.job_title}"
  end
end
