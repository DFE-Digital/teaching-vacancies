class AddEthosAndAimsToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :ethos_and_aims, :string
  end
end
