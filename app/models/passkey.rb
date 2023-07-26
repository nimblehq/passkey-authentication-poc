class Passkey < ApplicationRecord
  belongs_to :user

  def self.find_with_credential_id(id)
    self.find_by(external_id: id)
  end
end
