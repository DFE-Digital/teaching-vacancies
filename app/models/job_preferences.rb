class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  validates :jobseeker_profile, uniqueness: true

  def complete?
    steps = completed_steps.symbolize_keys
    %i[roles phases key_stages subjects working_patterns locations].all? { |step| steps.include?(step) && steps[step].to_sym.in?(%i[completed skipped]) }
  end
end
