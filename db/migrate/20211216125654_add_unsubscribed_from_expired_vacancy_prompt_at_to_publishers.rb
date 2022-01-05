class AddUnsubscribedFromExpiredVacancyPromptAtToPublishers < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :unsubscribed_from_expired_vacancy_prompt_at, :datetime
  end
end
