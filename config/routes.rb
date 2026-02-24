Rails.application.routes.draw do
  root "posts#index"

  # ── Authentication ──────────────────────────────────────────
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # ── Registration ────────────────────────────────────────────
  get  "/signup", to: "users#new",    as: :signup
  post "/signup", to: "users#create"

  # ── User profiles ───────────────────────────────────────────
  resources :users, only: [ :show ]

  # ── Posts + nested comments ─────────────────────────────────
  resources :posts do
    resources :comments, only: [ :create, :destroy ]
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
