lock "~> 3.20.0"

set :application, "interview_kanri"
set :repo_url, ENV.fetch("DEPLOY_REPO_URL", "git@github.com:example/interview_kanri.git")
set :branch, ENV.fetch("DEPLOY_BRANCH", "main")
set :deploy_to, "/var/www/interview_kanri"

set :rbenv_type, :user
set :rbenv_ruby, "3.2.0"

set :linked_files, %w[config/master.key]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets storage public/assets]
set :keep_releases, 5

set :unicorn_pid, "/var/www/interview_kanri/shared/tmp/pids/unicorn.pid"
set :unicorn_config_path, -> { File.join(current_path, "config", "unicorn", "production.rb") }

namespace :deploy do
  after :publishing, :restart

  desc "Restart Unicorn"
  task :restart do
    invoke "unicorn:legacy_restart"
  end
end
