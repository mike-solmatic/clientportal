Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # Root redirects based on role
  root "home#index"

  # Seller namespace
  namespace :seller do
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :customers
    resources :products
    resources :orders do
      resources :order_items, only: [:create, :update, :destroy]
      resources :payments, only: [:new, :create, :destroy]
      resource :invoice, only: [:show, :new, :create] do
        get :pdf, on: :member
      end
      member do
        patch :confirm
        patch :cancel
      end
    end
  end

  # Admin namespace
  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :sellers, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_active
      end
    end
    resources :users
  end
end
