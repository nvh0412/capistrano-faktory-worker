namespace :load do
  task :defaults do
    set :faktory_worker_default_hooks, true

    set :faktory_worker_pid, -> { File.join(shared_path, 'tmp', 'pids', 'faktory_worker.pid') }
    set :faktory_worker_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    set :faktory_worker_log, -> { File.join(shared_path, 'log', 'faktory_worker.log') }
    set :faktory_worker_roles, fetch(:faktory_worker_role, :app)
  end
end

namespace :deploy do
  before :starting, :check_faktory_worker_hooks do
    invoke 'faktory_worker:add_default_hooks' if fetch(:faktory_worker_default_hooks)
  end
end

namespace :faktory_worker do
  task :add_default_hooks do
    after 'deploy:starting', 'faktory_worker:quite'
    after 'deploy:updated', 'faktory_worker:stop'
    after 'deploy:published', 'faktory_worker:start'
    after 'deploy:failed', 'faktory_worker:restart'
  end
end
