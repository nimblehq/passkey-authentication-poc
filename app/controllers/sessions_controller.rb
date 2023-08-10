# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  respond_to :json

  def create
    email = session[:email] || session_params[:email]
    user = User.find_by(email: email)

    if user
      get_options = get_webauthn_options(user)

      session[:current_authentication] = { challenge: get_options.challenge, email: email }

      render json: get_options
    else
      render json: { errors: ["User doesn't exist"] }, status: :unprocessable_entity
    end
  end

  def callback
    webauthn_credential = WebAuthn::Credential.from_get(params)
    user = User.find_by(email: session['current_authentication']['email'])
    credential = user.credentials.find_by(external_id: webauthn_credential.id)

    if valid_webauthn_credential?(webauthn_credential, credential)
      credential.update!(sign_count: webauthn_credential.sign_count)
      sign_in(user)
      render json: { status: :ok }, status: :ok
    else
      render json: { status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out

    redirect_to root_path
  end

  private

  def get_webauthn_options(user)
    WebAuthn::Credential.options_for_get(
      allow: user.credentials.pluck(:external_id)
    )
  end

  def valid_webauthn_credential?(webauthn_credential, credential)
    verify_webauthn_credential(webauthn_credential, credential)
    true
  rescue WebAuthn::Error => e
    Rails.logger.error(e.message)
    session.delete('current_authentication')
    false
  end

  def verify_webauthn_credential(webauthn_credential, credential)
    webauthn_credential.verify(
      session['current_authentication']['challenge'],
      public_key: credential.public_key,
      sign_count: credential.sign_count
    )
  end

  def session_params
    params.require(:session).permit(:email)
  end
end
