Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users

  get '/users', to: 'users#index'

  root 'home#index'
end
