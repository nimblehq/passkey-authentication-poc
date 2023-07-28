# frozen_string_literal: true

module Devise
  module Strategies
    class PasswordPasskeyAuthenticatable < Devise::Strategies::DatabaseAuthenticatable
      # def valid?
      #   true
      # end
      def authenticate!
        resource  = password.present? && mapping.to.find_for_database_authentication(authentication_hash)
        hashed = false


        Rails.logger.debug '========'
        Rails.logger.debug resource
        Rails.logger.debug validate(resource)
        Rails.logger.debug resource.valid_password?(password)
        # if validate(resource){ hashed = true; resource.valid_password?(password) }

          Rails.logger.debug '===<>====='
          remember_me(resource)
          resource.after_database_authentication
          success!(resource)
        # end
        Rails.logger.debug '===xxxx====='

        # In paranoid mode, hash the password even when a resource doesn't exist for the given authentication key.
        # This is necessary to prevent enumeration attacks - e.g. the request is faster when a resource doesn't
        # exist in the database if the password hashing algorithm is not called.
        mapping.to.new.password = password if !hashed && Devise.paranoid
        unless resource
          Devise.paranoid ? fail(:invalid) : fail(:not_found_in_database)
        end
      end
    end
  end
end
