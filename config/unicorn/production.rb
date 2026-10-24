app_path = "/var/www/interview_kanri"
working_directory "#{app_path}/current"
pid "#{app_path}/shared/tmp/pids/unicorn.pid"
listen "#{app_path}/shared/tmp/sockets/unicorn.sock", backlog: 64

stderr_path "#{app_path}/shared/log/unicorn.stderr.log"
stdout_path "#{app_path}/shared/log/unicorn.stdout.log"

worker_processes Integer(ENV.fetch("WEB_CONCURRENCY", 2))
timeout 30
preload_app true

before_exec do |_server|
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/current/Gemfile"
end

before_fork do |server, _worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
