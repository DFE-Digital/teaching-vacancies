class AddLeadershipData < ActiveRecord::Migration[5.1]
  def change
    ['Executive Head', 'Headteacher',
     'Middle Leader', 'Multi-Academy Trust',
     'Senior Leader'].each do |leadership|
       Leadership.find_or_create_by(title: leadership)
     end
  end
end
