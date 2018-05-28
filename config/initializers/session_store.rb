Rails.application.config.session_store :active_record_store,
                                       key: '_teachingjobs_session',
                                       expire_after: 1.hour
