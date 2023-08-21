# frozen_string_literal: true

module Api
  class SignInController < ApplicationController

    def create
      user = User.find_by(email: session_params[:email])
  
      if user&.valid_password?(session_params[:password])
        if user.credentials.present?
          handle_2fa_path(user)
        else
          handle_normal_path(user)
        end
      else
        redirect_to request.referer
      end
    end
  
    def challenge
      email = session_params[:email]
      user = User.find_by(email: email)
  
      if user
        get_options = get_webauthn_options(user)
  
        user.update(current_challenge: get_options.challenge)

        render json: get_options
      else
        render json: { errors: ["User doesn't exist"] }, status: :unprocessable_entity
      end
    end
  
    def callback
      webauthn_credential = WebAuthn::Credential.from_get(params)
      user = User.find_by(email: session_params[:email])
  
      return render json: { status: :unprocessable_entity }, status: :unprocessable_entity unless user&.valid_password?(session_params[:password])

      credential = user.credentials.find_by(external_id: webauthn_credential.id)
  
      if valid_webauthn_credential?(webauthn_credential, credential, user)
        credential.update!(sign_count: webauthn_credential.sign_count)
        sign_in(user)

        render_success user
      else
        render json: { status: :unprocessable_entity }, status: :unprocessable_entity
      end
    end
  
    def destroy
      sign_out
  
      redirect_to root_path
    end
  
    private

    def render_success(user)
      access_token = Doorkeeper::AccessToken.create(
        resource_owner_id: user.id,
        use_refresh_token: true,
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        scopes: ''
      )

      render json: Doorkeeper::OAuth::TokenResponse.new(access_token).body
    end

    def get_webauthn_options(user)
      WebAuthn::Credential.options_for_get(
        allow: user.credentials.pluck(:external_id)
      )
    end

    def valid_webauthn_credential?(webauthn_credential, credential, user)
      verify_webauthn_credential(webauthn_credential, credential, user)
      true
    rescue WebAuthn::Error => e
      Rails.logger.error(e.message)
      false
    end

    def verify_webauthn_credential(webauthn_credential, credential, user)
      webauthn_credential.verify(
        user.current_challenge,
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )
    end

    def handle_2fa_path(user)
      session[:email] = user.email
    end

    def handle_normal_path(user)
      sign_in(user)

      render_success user
    end

    def session_params
      params.require(:session).permit(:email, :password)
    end
  end
end
