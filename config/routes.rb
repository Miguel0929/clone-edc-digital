Rails.application.routes.draw do
  devise_for :users, sign_out_via: [:get, :delete], :controllers => { :invitations => 'users/invitations', sessions: 'sessions' }

  root 'dashboard/welcome#index'

  get '/dashboard', to: 'dashboard/welcome#index', as: :welcome
  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#internal_error"

  resources :programs do
    resources :chapters, except: [:index, :show] do
      collection do
        post :sort
      end

      member do
        post :clone
      end
    end

    member do
      post :clone
    end
  end

  resources :chapters, only: [] do
    resources :lessons, except: [:index] do
      member do
        post :clone
      end
    end

    resources :questions, except: [:index, :show] do
      member do
        post :clone
      end
    end
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

    resources :evaluations, only: [:index, :show]
  end


  resources :users, except: [:create] do
    member do
      get :analytics_program
    end

    resources :programs, only: [] do
      resources :answers, only: [:index, :edit, :update]
    end
  end

  resources :mentors, except: [:create]

  resources :groups
  resources :visits, only: [:index]

  namespace :mentors do
    resources :groups, only: [:index, :show]
    resources :evaluations, only: [:index, :show, :update]
    resources :students, only: [:index, :show]
  end

  namespace :api do
    namespace :v1 do
      resources :user_answer_comments, only: [:index]
    end
  end


  match '/auth/sso/authorize' => 'auth#authorize', via: :all
  match '/auth/sso/access_token' => 'auth#access_token', via: :all
  match '/auth/sso/user' => 'auth#user', via: :all
  match '/oauth/token' => 'auth#access_token', via: :all

  mount Ckeditor::Engine => '/ckeditor'
end
