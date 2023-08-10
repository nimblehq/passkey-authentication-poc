# frozen_string_literal: true

module Api
  class RegistrationsController < ApplicationController
    # skip_before_action :doorkeeper_authorize!

    def create
      render json: ''
    end

    def challenge
      user = User.new(email: 'hello@me.com')
      get_options = get_webauthn_options(user)

      session[:current_authentication] = { challenge: get_options.challenge, email: 'hello@me.com' }

      render json: get_options
    end

    def get_webauthn_options(user)
      WebAuthn::Credential.options_for_get(
        allow: user.credentials.pluck(:external_id)
      )
    end
  end
end
