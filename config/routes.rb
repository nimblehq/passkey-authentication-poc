Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions'
  }

  devise_scope :user do
    post 'users/registrations/create', to: 'registrations#create', as: :create_registration

    post 'users/sessions/create', to: 'sessions#create', as: :create_session
    post 'users/sessions/create_passkey', to: 'sessions#create_passkey', as: :create_session_passkey
    post 'users/sessions/callback', to: 'sessions#callback', as: :callback_session
    
    get 'users/sessions/verify', to: 'sessions#verify', as: :verify

    get 'users', to: 'users#show', as: :user
    post 'users/credentials/add', to: 'users#add_credential', as: :add_credential
    post 'users/credentials/callback', to: 'users#callback', as: :callback_user
    delete 'users/credentials/destroy', to: 'users#destroy_credential', as: :destroy_credential
  end

  root to: 'home#show'

  get '.well-known/apple-app-site-association' => 'apple_well_known#apple_app_site_association'
  post 'api/registrations/challenge', to: 'api/registrations#challenge', as: :api_registration_challenge
  post 'api/registrations', to: 'api/password_registrations#create', as: :api_registration
  post 'api/registrations/callback', to: 'api/registrations#callback', as: :api_registration_callback
  post 'api/sign-in/challenge', to: 'api/sign_in#challenge', as: :api_sign_in_challenge_challenge
  post 'api/sign-in', to: 'api/sign_in#create', as: :api_sign_in_challenge
  post 'api/sign-in/callback', to: 'api/sign_in#callback', as: :api_sign_in_callback_challenge
end
