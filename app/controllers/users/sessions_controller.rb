# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  include Devise::Passkeys::Controllers::SessionsControllerConcern
  include RelyingParty

  def create
    self.resource = warden.authenticate!(auth_options)

    if resource.passkeys.any?
      warden.logout
      session[:webauthn_authentication] = {user_id: resource.id, remember_me: params[:user][:remember_me] == "1"}

      redirect_to webauthn_authentications_url, notice: "Use your authenticator to continue."
    else
      # continue without webauthn
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
