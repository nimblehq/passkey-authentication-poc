WebAuthn.configure do |config|
  # config.origin = "http://localhost:3000"

  config.origin = "https://rails-passkey-mobile-demo-90f7328f33ff.herokuapp.com"
  config.rp_name = "Passkey Authentication POC"
  config.encoding = :base64url
end
