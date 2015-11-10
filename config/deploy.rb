lock '3.3.5'

set :application, 'private_pub_server'
set :repo_url,    'https://github.com/he9lin/private_pub_server.git'
set :branch,      'v1'

set :deploy_to,   '/home/deployer/apps/main_app'
set :deploy_via,  :remote_cache
set :pty,         true
set :use_sudo,    false

set :env_file,    ".env"
set :proc_file,   "Procfile"

set :linked_files, ['config/private_pub.yml',
                    fetch(:env_file),
                    fetch(:proc_file),
                    '.rbenv-vars']

set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets}

set :rbenv_type, :user
set :rbenv_ruby, '2.1.2'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :foreman do
  desc "Start the application services"
  task :start do
    on roles(:app), in: :sequence do
      cmd = %w(sudo service private_pub_server start)
      execute *cmd
    end
  end

  desc 'Regenerate init file'
  task :export do
    on roles(:app), in: :sequence do
      within current_path do
        cmd = %w(sudo foreman export upstart /etc/init -a private_pub_server -u deployer -l /var/private_pub_server/log)
        execute *cmd
      end
    end
  end
  before :start, :export

  desc "Stop the application services"
  task :stop do
    on roles(:app), in: :sequence do
      cmd = %w(sudo service private_pub_server stop)
      execute *cmd
    end
  end
end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
    end
  end
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
