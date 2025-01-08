class AddCourseLengthToTrainingAndCpds < ActiveRecord::Migration[7.2]
  def change
    add_column :training_and_cpds, :course_length, :string
  end
end
