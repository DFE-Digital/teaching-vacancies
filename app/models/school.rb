class School < ApplicationRecord
  belongs_to :type, class_name: 'SchoolType', required: true
end
