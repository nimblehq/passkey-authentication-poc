# frozen_string_literal: true

class Users::PasskeysController < DeviseController
  include Devise::Passkeys::Controllers::PasskeysControllerConcern
  include RelyingParty

  def root_path
    "/"
  end

  def verify_reauthentication_token
    true
  end

  def ensure_at_least_one_passkey
    true
  end

  def user_details_for_registration
    { id: resource.webauthn_id || WebAuthn.generate_user_id, name: resource.email }
  end
end
