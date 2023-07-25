# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    @user = current_user
  end
end
