Rails.application.config.session_store :active_record_store,
                                       key: "_teachingvacancies_session",
                                       expire_after: ENV.fetch("SESSION_DAYS_TRIM_THRESHOLD", 14).to_i.days
