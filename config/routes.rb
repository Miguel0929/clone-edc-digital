Rails.application.routes.draw do
  devise_for :users

  resources :programs

  get '/users', to: 'users#index'

  root 'home#index'

  mount Ckeditor::Engine => '/ckeditor'
end
