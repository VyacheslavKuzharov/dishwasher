Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 300, wait_timeout: 300
