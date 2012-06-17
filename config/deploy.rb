def set_application_paths(app)
  set :deploy_to, "/opt/#{app}"
  set :staging_path, "/tmp/#{app}"
  set :local_path, Dir.pwd
  set :release_path, "#{deploy_to}/releases/#{Time.now.strftime("%Y%m%d%H%M")}"
end

def set_common_environment
  env :db_host, "localhost"
  env :db_name, "socialteeth"
  env :db_user, "socialteeth"
end

set :app, "socialteeth"
set_application_paths(app)
set :user, "socialteeth"

role :root_user, :user => "root"
role :socialteeth_user, :user => "socialteeth"

destination :vagrant do
  set :domain, "socialteeth-vagrant"
  set_common_environment
  env :rack_env, "production"
  env :port, 8200
end

destination :staging do
  set :app, "socialteeth_staging"
  set_application_paths(app)
  set :domain, "50.116.26.92"
  set_common_environment
  env :rack_env, "staging"
  env :db_name, "socialteeth_staging"
  env :db_user, "socialteeth_staging"
  env :port, 8100
  env :unicorn_workers, 2
  env :s3_bucket, "staging.socialteeth.org"
end

destination :prod do
  set :domain, "50.116.26.92"
  set_common_environment
  env :rack_env, "production"
  env :db_name, "socialteeth"
  env :db_user, "socialteeth"
  env :port, 8200
  env :unicorn_workers, 4
  env :s3_bucket, "socialteeth.org"
end

# Load secure credentials
if ENV.has_key?("SOCIALTEETH_CREDENTIALS") && File.exist?(ENV["SOCIALTEETH_CREDENTIALS"])
  load ENV["SOCIALTEETH_CREDENTIALS"]
else
  puts "Unable to locate the file $SOCIALTEETH_CREDENTIALS. You need this to deploy."
  exit 1
end
