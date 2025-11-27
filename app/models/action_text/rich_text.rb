# Custom ActionText::RichText model to handle encryption
class ActionText::RichText < ActiveRecord::Base
  self.ignored_columns = %w[body]
end