# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  respond_to :html

  def create
    user = User.create!(email: registration_params[:email], password: registration_params[:password])

    if user.valid?
      sign_in(user)

      redirect_to root_path
    else
      render html: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:email, :password, :label)
  end
end
