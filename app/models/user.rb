# frozen_string_literal: true

class User < ApplicationRecord
  has_many :credentials, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_initialize do
    self.webauthn_id ||= WebAuthn.generate_user_id
  end
end
