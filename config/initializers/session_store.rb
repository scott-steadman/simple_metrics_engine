# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simple_metrics_engine_session',
  :secret      => 'dc330350eba32ff8a67d5fe8194045374b6cfd780be5cff911c8022c517b7ed18ee093aa09a66b9d1045449e9c226095908600795a5b22f5773b46612f3c62f8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
