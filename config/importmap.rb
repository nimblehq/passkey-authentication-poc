# config/importmap.rb
# Pin npm packages by running ./bin/importmap

pin "rails_application", preload: true
pin "credential", preload: true
pin "messenger", preload: true
pin "controllers/add_credential_controller", preload: true
pin "controllers/new_registration_controller", preload: true
pin "controllers/new_session_controller", preload: true
pin "@github/webauthn-json/browser-ponyfill", to: "https://ga.jspm.io/npm:@github/webauthn-json@2.1.0/dist/esm/webauthn-json.browser-ponyfill.js"
