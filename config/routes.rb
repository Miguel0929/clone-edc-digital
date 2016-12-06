Rails.application.routes.draw do
  devise_for :users, :controllers => { :invitations => 'users/invitations' }

  devise_scope :user do
    root :to => 'devise/sessions#new'
  end

  get '/dashboard', to: 'dashboard/welcome#index', as: :welcome
  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#internal_error"

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
    get 'terminos-y-condiciones', to: 'welcome#terms', as: :terms
    get 'politica-de-privacidad', to: 'welcome#privacy', as: :privacy
    get 'ayuda',                  to: 'welcome#support', as: :support
    post 'send_support_email',    to: 'welcome#send_support_email'
    get 'confidencialidad-y-propiedad-industrial', to: 'welcome#service', as: :service

    resources :notifications, only: [:index, :show] do
      collection do
        post :mark_as_read
      end
    end

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


  resources :users, except: [:create] do
    member do
      get :analytics_program
    end

    collection do
      get :mentors
      get :students
    end

    resources :programs, only: [] do
      resources :answers, only: [:index, :edit, :update]
    end
  end

  resources :groups
  resources :visits, only: [:index]


  mount Ckeditor::Engine => '/ckeditor'
end
