class AddWorkingPatternData < ActiveRecord::Migration[5.2]
  def change
    {full_time: 'Full time', part_time: 'Part time'}.each do |slug, label|
      WorkingPattern.find_or_create_by(slug: slug, label: label)
    end
  end
end
