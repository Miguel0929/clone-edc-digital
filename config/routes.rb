Rails.application.routes.draw do

  post 'ratings/vote_chapter_content'
  post 'ratings/vote_program'
  get 'rating/program/:id', to: "ratings#show", as: "rating_program"

  resources :reports, only: [:index,:destroy,:create] do
    member do
      post :visto
    end
  end

  devise_for :users, sign_out_via: [:get, :delete], :controllers => { :invitations => 'users/invitations', sessions: 'sessions', :registrations => "registrations" }

  #root 'dashboard/programs#index'
  get '/', to: 'landings#index'
  root 'landings#index'

  get '/dashboard', to: 'dashboard/welcome#index', as: :welcome
  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#internal_error"

  resources :control_panel, only: [:index]

  resources :progress_panel, only: [:index, :show]
  resources :progress_updater, only: [:show]
  get '/massive_program_progress', to: 'progress_panel#massive_program_progress', as: :massive_program_progress
  get '/progress_panel_groups', to: 'progress_panel#progress_groups', as: :progress_panel_groups
  get '/progress_per_program', to: 'progress_panel#program_detail', as: :progress_per_program

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
        #get :rubrics
      end
    end

    member do
      post :clone
      post :notify_changes
      post :notify_null
    end
  end

  resources :quizzes do
    resources :quiz_questions
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

    member do
      get :content
      get :rubrics
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
    get 'ruta',                   to: 'welcome#pathway', as: :pathway
    get 'ruta-aprendizaje',       to: 'welcome#learning_path', as: :learning_path
    get 'calculator',       to: 'welcome#calculator', as: :calculator
    get 'calculator_method',       to: 'welcome#calculator_method', as: :calculator_method
    get 'notifications-panel',        to: 'welcome#notifications_panel', as: :notifications_panel
    post 'store-notifications-panel',        to: 'welcome#store_notifications_panel', as: :store_notifications_panel
    post 'change_tour_trigger', to: 'users#change_tour_trigger', as: 'change_tour_trigger'

    resources :sitemap, only: [:index]

    resources :users, only: [:show]

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
      post "rank"
    end


    resources :questions, only: [] do
      resources :comments, only: [:create]
    end

    resources :evaluations, only: [:index, :show]

    resources :attachments, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :quizzes, only: [:index, :show] do
      member do
        get :apply
        get :detail
      end
    end

    resources :quiz_answers, only: [:show, :new, :create, :update, :edit]

    resources :delireverables, only: [:index] do
      resources :delireverable_users, only: [:new, :create]
    end

    resources :template_refilables, only: [:index] do
      resources :refilables, only: [:new, :create, :show, :edit, :update,]
    end
  end


  resources :users, except: [:create] do
    collection do
      get :students
      get :exports
    end

    member do
      get :analytics_program
    end

    member do
      get :analytics_quiz
      get :change_state
    end

    resources :programs, only: [] do
      resources :answers, only: [:index, :edit, :update]
    end
  end
  post 'change_evaluation', to: 'users#change_evaluation', as: :change_evaluation_panel

  resources :mentors, except: [:create] do
    member do
      get :change_state
    end
  end
  resources :staffs, except: [:create]

  resources :groups do
    member do
      get :sort_route
      post :sort
      post :notification_route
    end
    member do
      get :student_control
      get :reassign_student
      post :unlink_student
      post '/unlink_group_student' => 'groups#unlink_student'
    end

  end
  post '/change_group' => 'groups#change_group'
  post '/no_group_students' => 'groups#no_group_students'

  resources :exporters, only: [:show]
  resources :groups
  resources :visits, only: [:index]
  resources :deleted_users, only: [:index, :update], path: 'usuarios-desactivados'

  namespace :mentor do
    resources :sitemap, only: [:index]
    resources :groups, only: [:index, :show]
    resources :evaluations, only: [:index, :show, :update]
    resources :program_details, only: [:index]
    resources :students, only: [:index, :show, :update] do
      resources :shared_attachments
      collection do
        get :exports
      end
      member do
        get :analytics_quiz
      end

      resources :delireverable_users, only: [:edit, :update]
      resources :refilables, only: [:show, :edit, :update]
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
    resources :programs, only: [:index, :show]
    resources :chapter_contents, path: 'course', only: [:show] do
      resources :answers, only: [:show, :new, :create] do
        collection do
          get :router
        end
      end
    end

  end

  namespace :api do
    namespace :v1 do
      resources :user_answer_comments, only: [:index]
      resources :static_login, only: [:create]
      resources :async_jobs, only: [:show]

      namespace :dashboard do
        resources :programs, only: [:index]
      end

      resources :users, only: [:index]
    end
  end

  resources :track_sessions, only: [:create]
  resources :shared_group_attachments

  namespace :baasstard do
    namespace :api do
      post 'users', to: 'users#show'
      post 'users/invite', to: 'users#invite'
      resources :groups, only: [:index]
    end
  end

  match '/auth/sso/authorize' => 'auth#authorize', via: :all
  match '/auth/sso/access_token' => 'auth#access_token', via: :all
  match '/auth/sso/user' => 'auth#user', via: :all
  match '/oauth/token' => 'auth#access_token', via: :all

  mount Ckeditor::Engine => '/ckeditor'

  resources :conversations do
    member do
      post :reply
      post :trash
      post :untrash
    end
  end
  get 'mailbox/inbox' => 'mailbox#inbox', as: :mailbox_inbox
  get 'mailbox/sent' => 'mailbox#sent', as: :mailbox_sent
  get 'mailbox/trash' => 'mailbox#trash', as: :mailbox_trash

  resources :frequents
  resources :frequent_categories
  get '/frequent_questions', to: "frequent_categories#index"
  resources :glossaries
  resources :glossary_categories
  get '/glossary', to: "glossary_categories#index"

  resources :route_texts
  resources :route_covers

  resources :group_invitations, only: [:new, :create, :show]
  resources :program_stats
  post '/save_program_stats' => 'program_stats#post'
  post '/save_program_active' => 'program_actives#post', as: :save_program_active
  get '/generate_group_stats/:id' => 'group_stats#post', as: :generate_group_stats

  resources :universities do
    collection do
      get :state
    end
  end

  namespace :search do
    resources :users, only: [:index]
  end

  resources :delireverable_packages do
    resources :delireverables do
      collection do
        post :sort
      end
    end
  end

  resources :template_refilables do
    collection do
      post :sort
    end
  end

  resources :learning_paths,  only: [:index, :new, :create, :destroy, :show] do
    resources :learning_path_programs, only: [:new, :create, :destroy] do
      collection do
        post :sort
      end
    end   
  end
  post "get_contents" => "learning_path_contents#get_contents"  
end
