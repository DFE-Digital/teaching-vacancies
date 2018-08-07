PP_TRANSACTIONS_BY_CHANNEL_TOKEN = ENV['PP_TRANSACTIONS_BY_CHANNEL_TOKEN']
PP_USER_SATISFACTION_TOKEN = ENV['PP_USER_SATISFACTION_TOKEN']

Rails.logger.info('***No Bearer token for Performance Platform transactions by channel') if PP_TRANSACTIONS_BY_CHANNEL_TOKEN.nil?

Rails.logger.info('***No Bearer token for Performance Platform user satisfaction') if PP_USER_SATISFACTION_TOKEN.nil?
