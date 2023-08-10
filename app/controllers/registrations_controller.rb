# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  def create
    user = User.new(email: registration_params[:email])
    create_options = create_webauthn_options(user)

    if user.valid?
      session[:current_registration] = { challenge: create_options.challenge, user_attributes: user.attributes }

      render json: create_options
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def callback
    webauthn_credential = WebAuthn::Credential.from_create(params)
    user = User.create!(session['current_registration']['user_attributes'])
    credential = create_webauthn_credential_for_user(user, webauthn_credential)

    if valid_webauthn_credential?(webauthn_credential) && credential.save
      sign_in(user)

      render json: { status: :ok }, status: :ok
    else
      render json: { status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:email, :label)
  end

  def create_webauthn_options(user)
    WebAuthn::Credential.options_for_create(
      user: { name: user.email, id: user.webauthn_id }
    )
  end

  def create_webauthn_credential_for_user(user, webauthn_credential)
    user.credentials.build(
      external_id: webauthn_credential.id,
      label: params[:credential_label],
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count
    )
  end

  def valid_webauthn_credential?(webauthn_credential)
    webauthn_credential.verify(session['current_registration']['challenge'])
    true
  rescue WebAuthn::Error => e
    Rails.logger.error(e.message)
    session.delete('current_registration')
    false
  end
end
