# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # this will do in order left to right
  devise :database_authenticatable,
         :passkey_authenticatable, 
         :registerable, :recoverable, :rememberable, :validatable
        #  :password_passkey_authenticatable
         
  has_many :passkeys, dependent: :destroy

  def self.passkeys_class
    Passkey
  end

  def self.find_for_passkey(passkey)
    self.find_by(id: passkey.user.id)
  end

  def after_passkey_authentication(passkey:)
  end 
end

Devise.add_module :passkey_authenticatable,
                  model: 'devise/passkeys/model',
                  route: {session: [nil, :new, :create, :destroy] },
                  controller: 'controller/sessions',
                  strategy: true,
                  no_input: true
# Devise.add_module :password_passkey_authenticatable,
#                   model: 'devise/passkeys/model',
#                   route: {session: [nil, :new, :create, :destroy] },
#                   controller: 'controller/sessions',
#                   strategy: true,
#                   no_input: true
