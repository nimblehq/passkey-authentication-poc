# frozen_string_literal: true

class Webauthn::AuthenticationsController < ApplicationController

  include RelyingParty

  def index
    user = User.find_by(id: session.dig(:webauthn_authentication, "user_id"))

    if user
      render :index, locals: {
        user: user
      }
    else
      redirect_to new_user_session_path, error: "Authentication error"
    end
  end

  def create
    # prepare needed data
    webauthn_credential = WebAuthn::Credential.from_get(JSON.parse(raw_credential), relying_party: relying_party)
    user = User.find(session[:webauthn_authentication]["user_id"])
    credential = user.passkeys.find_by(external_id: Base64.strict_encode64(webauthn_credential.raw_id))

    begin
      # verification
      webauthn_credential.verify(
        session["user_current_webauthn_authentication_challenge"],
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )

      # update the sign count
      credential.update!(sign_count: webauthn_credential.sign_count)

      # signing the user in manually
      sign_in(:user, user)

      # set the remember me
      user.remember_me! if session[:webauthn_authentication]["remember_me"]

      # set the redirect URL
      redirect = stored_location_for(user) || root_path

      # you can use flash messages here
      flash[:notice] = "Hey, welcome back!"

      redirect_to redirect
    rescue WebAuthn::Error => e
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    ensure
      session.delete(:webauthn_authentication)
    end
  end
  
  def root_path
    "/"
  end
  
  def raw_credential
    params[:user][:passkey_credential]
  end
end
