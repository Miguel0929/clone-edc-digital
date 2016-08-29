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
    resources :programs, only: [:index, :show] do
      member do
        get :resume
      end
    end

    resources :chapter_contents, path: 'course', only: [:show] do
      resources :answers, only: [:show, :new, :create, :update, :edit] do
        collection do
          get :router
        end
      end
    end

    resources :answers, only: [] do
      resources :comments, only: [:create]
    end
  end


  resources :users, only: [:index, :show, :edit, :update, :destroy] do
    collection do
      get :mentors
      get :students
    end

    resources :answers, only: [:index, :edit, :update]
  end

  resources :groups

  root 'home#index'

  mount Ckeditor::Engine => '/ckeditor'
end
