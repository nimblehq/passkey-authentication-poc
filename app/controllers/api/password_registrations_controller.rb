# frozen_string_literal: true

module Api
  class PasswordRegistrationsController < ApplicationController
  
    def create
      user = User.create!(email: registration_params[:email], password: registration_params[:password])
  
      if user.valid?
        sign_in(user)
  
        render json: {}
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private

    def registration_params
      params.require(:registration).permit(:email, :password, :label)
    end
  end
end
