class AddUserResearchParticipationRequestToGeneralFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :general_feedbacks, :user_participation_response, :integer
  end
end
