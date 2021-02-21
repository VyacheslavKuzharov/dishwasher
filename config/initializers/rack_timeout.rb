Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, wait_timeout: 300
