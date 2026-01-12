class AllowBlankRefereeEmails < ActiveRecord::Migration[8.0]
  def change
    change_column_null :reference_requests, :email, true
    change_column_null :reference_requests, :token, true
  end
end
