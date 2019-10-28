class AddUserParticipationResponseToVacancyPublishFeedback < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancy_publish_feedbacks, :email, :string
    add_column :vacancy_publish_feedbacks, :user_participation_response, :integer
  end
end
