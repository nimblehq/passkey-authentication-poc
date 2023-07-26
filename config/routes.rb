Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  namespace :webauthn do
    resources :authentications, only: %i[index create], path: :auth do
    end
  end

  devise_scope :user do
    post 'sign_up/new_challenge', to: 'users/registrations#new_challenge', as: :new_user_registration_challenge
    post 'sign_in/new_challenge', to: 'users/sessions#new_challenge', as: :new_user_session_challenge
  
    post 'reauthenticate/new_challenge', to: 'users/reauthentication#new_challenge', as: :new_user_reauthentication_challenge
    post 'reauthenticate', to: 'users/reauthentication#reauthenticate', as: :user_reauthentication
  
    namespace :users do
      resources :passkeys, only: [:index, :create, :destroy] do
        collection do
          post :new_create_challenge
        end
  
        member do
          post :new_destroy_challenge
        end
      end
    end
  end
end
