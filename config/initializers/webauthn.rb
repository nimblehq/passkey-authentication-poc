WebAuthn.configure do |config|
  config.origin = "http://localhost:3000"
  config.rp_name = "Passkey Authentication POC"
end
