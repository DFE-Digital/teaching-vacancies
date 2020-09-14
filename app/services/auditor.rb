module Auditor
  class Audit
    attr_reader :model, :key, :session_id

    def initialize(model, key, session_id)
      @model = model
      @key = key
      @session_id = session_id
    end

    def log(&block)
      changes = model.changes
      yield block if block
      create(changes)
    end

    def log_without_association
      create_without_model
    end

  private

    def create(changes)
      PublicActivity::Activity.create trackable: model, key: key, session_id: session_id, parameters: changes
    end

    def create_without_model
      PublicActivity::Activity.new(key: key, session_id: session_id).save(validate: false)
    end
  end

  module Model
    def activities
      PublicActivity::Activity.where(trackable: self)
    end
  end

  class Auth
    def yesterdays_activities
      sql = "(key like 'azure%' or key LIKE 'dfe-sign-in%') and date(created_at) = (current_date - 1)"
      PublicActivity::Activity.where(sql)
    end
  end
end
