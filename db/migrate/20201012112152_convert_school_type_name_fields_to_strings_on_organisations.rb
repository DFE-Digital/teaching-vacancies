class ConvertSchoolTypeNameFieldsToStringsOnOrganisations < ActiveRecord::Migration[6.0]
  def change
    School.all.in_batches(of: 100).each_record do |organisation|
      organisation.update_columns(school_type_name: organisation&.school_type&.label,
                                  detailed_school_type_name: organisation&.detailed_school_type&.label)
    end
  end
end
