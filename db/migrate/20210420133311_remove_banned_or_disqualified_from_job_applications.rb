class RemoveBannedOrDisqualifiedFromJobApplications < ActiveRecord::Migration[6.1]
  def change
    remove_column :job_applications, :banned_or_disqualified, :string
  end
end
