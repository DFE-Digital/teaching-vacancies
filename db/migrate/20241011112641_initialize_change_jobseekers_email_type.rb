class InitializeChangeJobseekersEmailType < ActiveRecord::Migration[7.1]
  def change
    enable_extension("citext")

    initialize_column_type_change :jobseekers, :email, :citext
  end
end
