require "fileutils"
require "terraform"

namespace :fezzik do
  desc "stages the project for deployment in /tmp"
  task :stage do
    puts "staging project in #{staging_path}"
    FileUtils.rm_rf staging_path
    FileUtils.mkdir_p "#{staging_path}/staged"
    # Use rsync to preserve executability and follow symlinks.
    system("rsync -aqE --exclude='public/uploads' --exclude='.git' #{local_path}/. #{staging_path}/staged")
    Terraform.write_dsl_file("#{staging_path}/staged/script/")
  end

  desc "performs pre-push setup"
  remote_task :pre_push_setup, :roles => :root_user do
    puts "performing pre-push setup"
    add_user("socialteeth") unless has_user?("socialteeth")
    run "ruby --version || apt-get install -y ruby"
    run "mkdir -p /opt/#{app}/releases && chown -R socialteeth /opt/#{app}"
  end

  desc "performs post-push setup"
  remote_task :post_push_setup, :roles => :socialteeth_user do
    puts "performing post-push setup"
    run "cd #{release_path} && ./script/system_setup.rb"
    puts "bundle install"
    run "cd #{release_path} && bundle install"
    puts "running migrations"
    run "cd #{release_path} && ./script/run_migrations.rb"
    Rake::Task["fezzik:generate_upstart_scripts"].invoke
  end

  desc "generates upstart scripts"
  remote_task :generate_upstart_scripts, :roles => :socialteeth_user do
    puts "generating upstart scripts"
    run "cd #{release_path} && bundle exec foreman export upstart upstart_scripts -a #{app} -u #{user}"
    run "sudo cp #{current_path}/upstart_scripts/* /etc/init"
  end

  desc "rsyncs the project from its staging location a destination server"
  remote_task :push => [:stage, :pre_push_setup] do
    puts "pushing to #{target_host}:#{release_path}"
    # Copy on top of previous release to optimize rsync
    rsync "-q", "--copy-dest=#{current_path}", "/tmp/#{app}/staged/", "#{target_host}:#{release_path}"
  end

  desc "symlinks the latest deployment to /deploy_path/project/current"
  remote_task :symlink do
    puts "symlinking current to #{release_path}"
    run "cd #{deploy_to} && ln -fns #{release_path} current"
  end

  desc "runs the executable in project/bin"
  remote_task :start do
    puts "starting from #{capture_output { run "readlink #{current_path}" }}"
    run "sudo start #{app} 2> /dev/null || true"
  end

  desc "kills the application by searching for the specified process name"
  remote_task :stop do
    puts "stopping #{app}"
    run "sudo stop #{app} 2> /dev/null || true"
  end

  desc "restarts the application"
  remote_task :restart do
    Rake::Task["fezzik:stop"].invoke
    Rake::Task["fezzik:start"].invoke
  end

  desc "display application status"
  remote_task :status do
    run "sudo status #{app}"
  end

  desc "full deployment pipeline"
  task :deploy do
    Rake::Task["fezzik:push"].invoke
    Rake::Task["fezzik:post_push_setup"].invoke
    Rake::Task["fezzik:symlink"].invoke
    Rake::Task["fezzik:restart"].invoke
    puts "#{app} deployed!"
  end

  def run_commands(*commands) run commands.join(" && ") end

  def has_user?(username)
    capture_output { run("getent passwd #{username} || true") }.size > 0
  end

  def add_user(username)
    puts "creating user #{username}"
    run_commands(
      "useradd --create-home --shell /bin/bash #{username}",
      "adduser #{username} --add_extra_groups admin",
      "mkdir -p /home/#{username}/.ssh",
      "cp ~/.ssh/authorized_keys /home/#{username}/.ssh",
      "chown -R #{username} /home/#{username}/.ssh"
    )
    # Ensure users in the "admin" group can passwordless sudo.
    sudoers_line = "'%admin ALL=NOPASSWD:ALL'"
    run "echo #{sudoers_line} >> /etc/sudoers"
  end
end
