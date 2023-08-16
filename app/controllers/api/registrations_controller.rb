# frozen_string_literal: true

module Api
  class RegistrationsController < ApplicationController
    # skip_before_action :doorkeeper_authorize!

    def challenge
      user = User.find_by(email: params[:email])
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
      credential = create_webauthn_credential_for_user(webauthn_credential)
  
      if valid_webauthn_credential?(webauthn_credential) && credential.save
        render json: { status: :ok }, status: :ok
      else
        render json: { status: :unprocessable_entity }, status: :unprocessable_entity
      end
    end
  
    def destroy_credential
      credential = current_user.credentials.first
      credential.destroy if credential.present?
  
      redirect_to request.referer
    end
  
    private
  
    def create_webauthn_options(user)
      WebAuthn::Credential.options_for_create(
        user: { name: user.email, id: user.webauthn_id }
      )
    end

    def create_webauthn_credential_for_user(webauthn_credential)
      current_user.credentials.build(
        external_id: webauthn_credential.id,
        label: params[:credential_label],
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )
    end
  
    def valid_webauthn_credential?(webauthn_credential)
      webauthn_credential.verify(session[:current_challenge])
      true
    rescue WebAuthn::Error => e
      Rails.logger.error(e.message)
      session.delete('current_challenge')
      false
    end
  end
end
