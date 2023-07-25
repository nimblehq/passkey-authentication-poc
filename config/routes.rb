Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions'
  }

  devise_scope :user do
    post 'users/registrations/create', to: 'registrations#create', as: :create_registration
    post 'users/registrations/callback', to: 'registrations#callback', as: :callback_registration

    post 'users/sessions/create', to: 'sessions#create', as: :create_session
    post 'users/sessions/callback', to: 'sessions#callback', as: :callback_session

    get 'users', to: 'users#show', as: :user
    post 'users/credentials/add', to: 'users#add_credential', as: :add_credential
    post 'users/credentials/callback', to: 'users#callback', as: :callback_user
    delete 'users/credentials/destroy', to: 'users#destroy_credential', as: :destroy_credential
  end

  root to: 'home#show'
end
