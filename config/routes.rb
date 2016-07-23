Rails.application.routes.draw do
  devise_for :users

  resources :programs do
    resources :chapters, except: [:index, :show]
  end

  resources :chapters, only: [] do
    resources :stages, except: [:index, :show]
  end

  resources :stages, only: [] do
    resources :lessons, except: [:index]
    resources :questions, except: [:index, :show]
  end

  resources :stage_contents, only: [] do
    collection do
      post :sort
    end
  end

  get '/users', to: 'users#index'

  root 'home#index'

  mount Ckeditor::Engine => '/ckeditor'
end
