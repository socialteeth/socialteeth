set :app, "socialteeth"
set :deploy_to, "/opt/#{app}"
set :staging_path, "/tmp/#{app}"
set :local_path, Dir.pwd
set :release_path, "#{deploy_to}/releases/#{Time.now.strftime("%Y%m%d%H%M")}"
set :user, "socialteeth"

role :root_user, :user => "root"
role :socialteeth_user, :user => "socialteeth"

destination :vagrant do
  set :domain, "socialteeth-vagrant"
  env :db_host, "localhost"
  env :db_name, "socialteeth"
  env :db_user, "socialteeth"
  env :port, 8090
end

# Load secure credentials
if ENV.has_key?("SOCIALTEETH_CREDENTIALS") && File.exist?(ENV["SOCIALTEETH_CREDENTIALS"])
  load ENV["SOCIALTEETH_CREDENTIALS"]
else
  puts "Unable to locate the file $SOCIALTEETH_CREDENTIALS. You need this to deploy."
  exit 1
end
