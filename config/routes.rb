Rails.application.routes.draw do
  devise_for :users

  resources :programs do
    resources :chapters, except: [:index, :show]
  end

  get '/users', to: 'users#index'

  root 'home#index'

  mount Ckeditor::Engine => '/ckeditor'
end
