#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "terraform_dsl"))
require File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), "environment"))

include Terraform::DSL

unless (`lsb_release --id`["Ubuntu"] rescue nil)
  fail_and_exit "This setup script is intended for Ubuntu."
end

ensure_packages(
  "nginx",
  "postgresql",
  "postgresql-client",
  "libpq-dev",
  "libfreeimage3",
  "libfreeimage-dev"
)

ensure_file("config/system_config_files/.bashrc", "#{ENV['HOME']}/.bashrc")

ensure_rbenv_ruby("1.9.2-p290")
ensure_gem("bundler")

# Nginx configurations

ensure_run_once("nginx site-enabled has correct permissions") do
  shell("sudo chgrp admin -R /etc/nginx/sites-enabled")
  shell("sudo chmod g+w -R /etc/nginx/sites-enabled")
end

dep "remove default nginx configuration" do
  met? { !File.exists?("/etc/nginx/sites-enabled/default") }
  meet { shell("sudo rm -f /etc/nginx/sites-enabled/default") }
end

ensure_file("config/system_config_files/nginx.socialteeth.conf", "/etc/nginx/sites-enabled/socialteeth.conf") do
  shell("sudo /etc/init.d/nginx restart")
end


# Javascript runtime for compiling coffeescript

ensure_ppa("ppa:chris-lea/node.js") # This PPA is endorsed on the node GH wiki
dep "node.js" do
  met? { in_path?("node") }
  meet { install_package("nodejs") }
end


# Database configurations

dep "create database" do
  met? { `sudo su postgres -c "psql --list -tA | cut -d '|' -f 1"`.split("\n").include?(DB_NAME) }
  meet { shell("sudo su postgres -c 'createdb #{DB_NAME} -l en_US.utf8 -E utf8 -T template0'") }
end

dep "create socialteeth database user" do
  users_sql = "select usename from pg_user"
  met? { `sudo su postgres -c "psql #{DB_NAME} -tc '#{users_sql}'"`.split("\n").map(&:strip).include?(DB_USER) }
  meet do
    create_user_sql = "CREATE USER #{DB_USER} WITH PASSWORD '\"'\"'#{DB_PASS}'\"'\"'"
    shell(%Q{sudo su postgres -c 'psql -c "#{create_user_sql}"'})
    shell(%Q{sudo su postgres -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE #{DB_NAME} TO #{DB_USER}'"})
  end
end

satisfy_dependencies
