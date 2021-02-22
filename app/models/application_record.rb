class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_create { EventContext.trigger_event(:entity_created, entity: self.class.name) }
  after_update { EventContext.trigger_event(:entity_updated, entity: self.class.name) }
  after_destroy { EventContext.trigger_event(:entity_destroyed, entity: self.class.name) }
end
