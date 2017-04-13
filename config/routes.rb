Rails.application.routes.draw do
  devise_for :users, sign_out_via: [:get, :delete], :controllers => { :invitations => 'users/invitations', sessions: 'sessions' }

  root 'dashboard/programs#index'

  get '/dashboard', to: 'dashboard/welcome#index', as: :welcome
  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#internal_error"

  resources :programs do
    collection do
      post :sort
    end

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
    get 'acerca-de',              to: 'welcome#index', as: :about
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
      post "mailer_interno"
    end

    resources :questions, only: [] do
      resources :comments, only: [:create]
    end

    resources :evaluations, only: [:index, :show]

    resources :attachments, only: [:index, :new, :create, :edit, :update, :destroy]
  end


  resources :users, except: [:create] do
    collection do
      get :students
    end

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
  resources :deleted_users, only: [:index, :update], path: 'usuarios-desactivados'

  namespace :mentor do
    resources :groups, only: [:index, :show]
    resources :evaluations, only: [:index, :show, :update]
    resources :students, only: [:index, :show] do
      resources :shared_attachments
    end
    resources :comments, only: [:index, :create, :update] do
      collection do
        get :archived
        get :news
      end
    end
    resources :questions, only: [:show] do
      resources :question_comments, only: [:create]
    end

    resources :shared_group_attachments
  end

  namespace :api do
    namespace :v1 do
      resources :user_answer_comments, only: [:index]
      resources :static_login, only: [:create]

      namespace :dashboard do
        resources :programs, only: [:index]
      end
    end
  end

  resources :track_sessions, only: [:create]
  resources :shared_group_attachments
  
  namespace :baasstard do
    namespace :api do
      post 'users', to: 'users#show'
    end
  end

  match '/auth/sso/authorize' => 'auth#authorize', via: :all
  match '/auth/sso/access_token' => 'auth#access_token', via: :all
  match '/auth/sso/user' => 'auth#user', via: :all
  match '/oauth/token' => 'auth#access_token', via: :all

  mount Ckeditor::Engine => '/ckeditor'
end
