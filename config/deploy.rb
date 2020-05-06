# config valid for current version and patch releases of Capistrano
###lock "~> 3.11.0"

###set :application, "my_app_name"
###set :repo_url, "git@example.com:me/my_repo.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

#Los tutoriales decían 'reemplazar' el contenido así que todo lo anterior se comentó. Los que tienen tres ### es porque son los que
#estaban sin comentar antes de hacer los cambios. Lo siguiente es lo que dicen que de debe poner:

# Change these
server '104.248.68.112', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@bunkrbit.com:software/edc_clone_deploy.git'
set :application,     'edc_clone_deploy'
set :user,            'rails'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

#SKIP PRECOMPILE
# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
# clear the previous precompile task
Rake::Task["deploy:assets:precompile"].clear_actions
class PrecompileRequired < StandardError; end
#SKIP PRECOMPILE

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

#SKIP PRECOMPILE - START
namespace :deploy do
  namespace :assets do
    desc "Precompile assets"
    task :precompile do
      on roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            begin
              # find the most recent release
              latest_release = capture(:ls, '-xr', releases_path).split[1]

              # precompile if this is the first deploy
              raise PrecompileRequired unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # precompile if the previous deploy failed to finish precompiling
              execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise(PrecompileRequired)

              fetch(:assets_dependencies).each do |dep|
                # execute raises if there is a diff
                execute(:diff, '-Naur', release_path.join(dep), latest_release_path.join(dep)) rescue raise(PrecompileRequired)
              end

              info("Skipping asset precompile, no asset diff found")

              # copy over all of the assets from the last release
              execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_path.join('public', fetch(:assets_prefix)))
            rescue PrecompileRequired
              execute(:rake, "assets:precompile") 
            end
          end
        end
      end
    end
  end
end
#SKIP PRECOMPILE - END

#EXECUTE ELASTICSEARCH CHECK - START
task :check_elasticsearch do
  on roles(:app) do
    execute "/usr/local/bin/check_restart_elasticsearch.txt"
  end
end
after "deploy", "check_elasticsearch"
#EXECUTE ELASTICSEARCH CHECK - END

namespace :rails do
  desc "Remote console"
  task :console do
    on roles(:app) do |h|
      run_interactively "bundle exec rails console #{fetch(:rails_env)}", fetch(:user)
    end
  end

  desc "Remote dbconsole"
  task :dbconsole do
    on roles(:app) do |h|
      run_interactively "bundle exec rails dbconsole #{fetch(:rails_env)}", fetch(:user)
    end
  end

  def run_interactively(command, user)
    info "Running `#{command}` as #{user}@#{host}"
    exec %Q(ssh #{user}@#{host} -t "bash --login -c 'cd #{fetch(:deploy_to)}/current && #{command}'")
  end
end

namespace :memcached do
 
  desc "Flushes memcached local instance"
  task :flush do
    on roles(:app) do |h|
      run("cd #{fetch(:deploy_to)}/current && rake memcached:flush")
    end
  end
 
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma