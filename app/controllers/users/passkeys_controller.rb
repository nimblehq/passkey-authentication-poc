# frozen_string_literal: true

class Users::PasskeysController < DeviseController
  include Devise::Passkeys::Controllers::PasskeysControllerConcern
  include RelyingParty
end
