class AddNeedsQtsStatus < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    add_column :vacancies, :fe_role_qts_required, :boolean
    add_column :vacancy_templates, :fe_role_qts_required, :boolean
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
