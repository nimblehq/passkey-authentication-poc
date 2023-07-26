class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
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
