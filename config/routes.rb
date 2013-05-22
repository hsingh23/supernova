Supernova::Application.routes.draw do
  # devise_scope :users do
  #   get '/sign_in' => "devise/sessions#new", as: :sign_in
  # end
  devise_for :users
  
  root to: "home#index"
  get '/sign_out' => "devise/sessions#destroy", as: :sign_out
end
