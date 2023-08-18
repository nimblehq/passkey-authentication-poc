# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def add_credential
    create_options = WebAuthn::Credential.options_for_create(
      user: { name: current_user.email, id: current_user.webauthn_id },
      exclude: current_user.credentials.pluck(:external_id)
    )

    session[:current_challenge] = create_options.challenge

    Rails.logger.info create_options.inspect
    Rails.logger.info create_options.challenge
    Rails.logger.info '===this'

    render json: create_options
  end

  def callback
    credential_hash = JSON.parse(params[:credential][:credential])
    webauthn_credential = WebAuthn::Credential.from_create(credential_hash)
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

  def create_webauthn_credential_for_user(webauthn_credential)
    current_user.credentials.build(
      external_id: webauthn_credential.id,
      label: params[:credential][:credential_label],
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count
    )
  end

  def valid_webauthn_credential?(webauthn_credential)
    Rails.logger.info webauthn_credential.response.client_data.inspect
    Rails.logger.info session[:current_challenge]
    Rails.logger.info webauthn_credential.response.client_data.challenge
    Rails.logger.info '===find'
    Rails.logger.warn OpenSSL.secure_compare(webauthn_credential.response.client_data.challenge, session[:current_challenge])
    Rails.logger.warn OpenSSL.secure_compare(webauthn_credential.response.client_data.challenge, webauthn_credential.response.client_data.challenge)

    webauthn_credential.verify(session[:current_challenge])
    true
  rescue WebAuthn::Error => e
    Rails.logger.error(e.message)
    session.delete('current_challenge')
    false
  end
end
