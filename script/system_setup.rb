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

# TODO: configure nginx

ensure_ppa("ppa:chris-lea/node.js") # This PPA is endorsed on the node GH wiki
dep "node.js" do
  met? { in_path?("node") }
  meet { install_package("nodejs") }
end

dep "create database" do
  met? { `sudo su postgres -c "psql --list"`.include?("socialteeth") }
  meet { shell("sudo su postgres -c 'createdb socialteeth -l en_US.utf8 -E utf8 -T template0'") }
end

dep "create socialteeth database user" do
  list_users_sql = "select usename from pg_user"
  met? { `sudo su postgres -c "psql socialteeth -tc '#{list_users_sql}'"`.include?("socialteeth") }
  meet do
    create_user_sql = "CREATE USER socialteeth WITH PASSWORD '\"'\"'#{DB_PASS}'\"'\"'"
    shell(%Q{sudo su postgres -c 'psql -c "#{create_user_sql}"'})
    shell(%Q{sudo su postgres -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE socialteeth TO socialteeth'"})
  end
end

satisfy_dependencies
