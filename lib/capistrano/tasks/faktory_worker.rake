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
    after 'deploy:updated', 'faktory_worker:stop'
    after 'deploy:published', 'faktory_worker:start'
  end

  task :stop do
    on roles fetch(:faktory_worker_roles) do |role|
      switch_user(role) do
        if test("[ -d #{release_path} ]")
          each_process_with_index(reverse: true) do |pid_file, _idx|
            if pid_file_exists?(pid_file) && process_exists?(pid_file)
              execute "kill -9 $( cat #{pid_file} )"
            end
          end
        end
      end
    end
  end

  task :start do
    execute "bundle exec faktory-worker"
  end

  def each_process_with_index(reverse: false)
    pid_file_list = pid_files
    pid_file_list.reverse! if reverse
    pid_file_list.each_with_index do |pid_file, idx|
      within release_path do
        yield(pid_file, idx)
      end
    end
  end

  def pid_files
    roles = Array(fetch(:faktory_worker_roles)).dup
    roles.select! { |role| host.roles.include?(role) }
    roles.flat_map do |role|
      Array.new(1) { |idx| fetch(:faktory_worker_pid).gsub(/\.pid$/, "-#{idx}.pid") }
    end
  end

  def process_exists?(pid_file)
    test(*("kill -0 $( cat #{pid_file} )").split(' '))
  end

  def pid_file_exists?(pid_file)
    test(*("[ -f #{pid_file} ]").split(' '))
  end

  def switch_user(role)
    su_user = faktory_user(role)
    if su_user == role.user
      yield
    else
      as su_user do
        yield
      end
    end
  end

  def faktory_user(role)
    role.properties.fetch(:run_as) || role.user
  end
end
