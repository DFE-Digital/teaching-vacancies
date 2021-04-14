class CreateEqualOpportunityReports < ActiveRecord::Migration[6.1]
  def change
    create_table :equal_opportunity_reports, id: :uuid do |t|
      t.uuid :vacancy_id, null: false
      t.integer "total_submissions", default: 0, null: false

      t.integer "disability_no", default: 0, null: false
      t.integer "disability_prefer_not_to_say", default: 0, null: false
      t.integer "disability_yes", default: 0, null: false

      t.integer "gender_man", default: 0, null: false
      t.integer "gender_other", default: 0, null: false
      t.integer "gender_prefer_not_to_say", default: 0, null: false
      t.integer "gender_woman", default: 0, null: false
      t.string "gender_other_descriptions", default: [], null: false, array: true

      t.integer "orientation_bisexual", default: 0, null: false
      t.integer "orientation_gay_or_lesbian", default: 0, null: false
      t.integer "orientation_heterosexual", default: 0, null: false
      t.integer "orientation_other", default: 0, null: false
      t.integer "orientation_prefer_not_to_say", default: 0, null: false
      t.string "orientation_other_descriptions", default: [], null: false, array: true

      t.integer "ethnicity_asian", default: 0, null: false
      t.integer "ethnicity_black", default: 0, null: false
      t.integer "ethnicity_mixed", default: 0, null: false
      t.integer "ethnicity_other", default: 0, null: false
      t.integer "ethnicity_prefer_not_to_say", default: 0, null: false
      t.integer "ethnicity_white", default: 0, null: false
      t.string "ethnicity_other_descriptions", default: [], null: false, array: true

      t.integer "religion_buddhist", default: 0, null: false
      t.integer "religion_christian", default: 0, null: false
      t.integer "religion_hindu", default: 0, null: false
      t.integer "religion_jewish", default: 0, null: false
      t.integer "religion_muslim", default: 0, null: false
      t.integer "religion_none", default: 0, null: false
      t.integer "religion_other", default: 0, null: false
      t.integer "religion_prefer_not_to_say", default: 0, null: false
      t.integer "religion_sikh", default: 0, null: false
      t.string "religion_other_descriptions", default: [], null: false, array: true

      t.timestamps
    end
  end
end
