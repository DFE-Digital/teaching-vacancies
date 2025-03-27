class AddDraftVacancy < ActiveRecord::Migration[7.2]
  def change
    #  This is a spike
    # safety_assured { add_column :vacancies, :type, :string, null: false, default: "RealVacancy" }
    safety_assured { add_column :vacancies, :type, :string, null: false }
  end
end
