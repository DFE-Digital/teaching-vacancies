PP_TRANSACTIONS_BY_CHANNEL_TOKEN = ENV['PP_TRANSACTIONS_BY_CHANNEL_TOKEN']
PP_USER_SATISFACTION_TOKEN = ENV['PP_USER_SATISFACTION_TOKEN']

if PP_TRANSACTIONS_BY_CHANNEL_TOKEN.nil?
  Rails.logger.error('***No Bearer token for Performance Platform transactions by channel')
end

if PP_USER_SATISFACTION_TOKEN.nil?
  Rails.logger.error('***No Bearer token for Performance Platform user satisfaction')
end
