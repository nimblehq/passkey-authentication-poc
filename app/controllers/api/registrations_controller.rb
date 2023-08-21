# frozen_string_literal: true

module Api
  class RegistrationsController < ApplicationController
    # skip_before_action :doorkeeper_authorize!
    before_action :doorkeeper_authorize!

    def challenge
      user = current_user
      create_options = create_webauthn_options(user)
  
      if user.valid?  
        render json: create_options
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def callback
      user = current_user
      webauthn_credential = WebAuthn::Credential.from_create(params)
      credential = create_webauthn_credential_for_user(webauthn_credential, user)
  
      if valid_webauthn_credential?(webauthn_credential, user) && credential.save
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

    def current_user
      @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
    end

    def create_webauthn_options(user)
      options = WebAuthn::Credential.options_for_create(
        user: { name: user.email, id: user.webauthn_id },
        exclude: user.credentials.pluck(:external_id)
      )
      user.update(current_challenge: options.challenge)
      Rails.logger.warn options.challenge
      Rails.logger.info user.current_challenge

      options
    end

    def create_webauthn_credential_for_user(webauthn_credential, user)
      Rails.logger.warn user
      Rails.logger.info webauthn_credential
      user.credentials.build(
        external_id: webauthn_credential.id,
        label: params[:credential_label],
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )
    end
  
    def valid_webauthn_credential?(webauthn_credential, user)
      webauthn_credential.verify(user.current_challenge)
      true
    rescue WebAuthn::Error => e
      Rails.logger.error(e.message)
      session.delete('current_challenge')
      false
    end
  end
end
