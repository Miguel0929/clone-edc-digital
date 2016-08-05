Rails.application.routes.draw do
  devise_for :users

  resources :programs do
    resources :chapters, except: [:index, :show]
  end

  resources :chapters, only: [] do
    resources :lessons, except: [:index]
    resources :questions, except: [:index, :show]
  end


  resources :chapter_contents, only: [] do
    collection do
      post :sort
    end
  end

  namespace :dashboard do
    resources :programs, only: [:index, :show]
    resources :chapter_contents, path: 'course', only: [:show] do
      resources :answers, only: [:new, :create, :update]
    end

    resources :answers, only: [] do
      resources :comments, only: [:create]
    end
  end

  get '/users', to: 'users#index'

  resources :users, only: [] do
    resources :answers, only: [:index]
  end

  resources :answers


  root 'home#index'

  mount Ckeditor::Engine => '/ckeditor'
end
