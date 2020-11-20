class ChangeDeviseIpColumnsToString < ActiveRecord::Migration[6.0]
  def change
    change_table :jobseekers do |t|
      t.change :current_sign_in_ip, :string
      t.change :last_sign_in_ip, :string
    end
  end
end
