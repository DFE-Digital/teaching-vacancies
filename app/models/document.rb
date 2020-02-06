class Document < ApplicationRecord
  belongs_to :vacancy, optional: true
end
