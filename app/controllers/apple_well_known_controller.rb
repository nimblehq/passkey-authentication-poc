# frozen_string_literal: true

class AppleWellKnownController < ApplicationController
  def apple_app_site_association
    render :json => {
      "webcredentials": {
        "apps": [
          "93QF44Z6JU.co.nimblehq.passkey"
        ]
      }
    }
  end
end
