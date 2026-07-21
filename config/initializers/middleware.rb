require_relative '../../app/middleware/vulnerable_auth'
Rails.application.config.middleware.use VulnerableAuth
