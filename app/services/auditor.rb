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

    private

    def create(changes)
      PublicActivity::Activity.create trackable: model, key: key, session_id: session_id, parameters: changes
    end
  end

  module Model
    def activities
      PublicActivity::Activity.where(trackable: self)
    end
  end
end
