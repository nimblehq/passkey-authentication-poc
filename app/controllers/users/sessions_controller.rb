# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Devise::Passkeys::Controllers::SessionsControllerConcern
  include RelyingParty
end
