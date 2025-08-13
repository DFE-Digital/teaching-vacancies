class RemoveJobReferenceDefaultBooleans < ActiveRecord::Migration[7.2]
  def change
    change_column_null :job_references, :can_give_reference, true
    change_column_default :job_references, :can_give_reference, from: true, to: nil

    %i[is_reference_sharable currently_employed would_reemploy_current would_reemploy_any].each do |column|
      change_column_null :job_references, column, true
      change_column_default :job_references, column, from: false, to: nil
    end
  end
end
