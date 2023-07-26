# frozen_string_literal: true

class Users::ReauthenticationController < DeviseController
  include Devise::Passkeys::Controllers::ReauthenticationControllerConcern
  include RelyingParty
end
