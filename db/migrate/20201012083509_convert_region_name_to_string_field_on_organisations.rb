class ConvertRegionNameToStringFieldOnOrganisations < ActiveRecord::Migration[6.0]
  def change
    School.all.in_batches(of: 100).each_record do |organisation|
      organisation.update_columns(region_name: organisation&.region&.name)
    end
  end
end
