namespace :fezzik do
  desc "Seeds the database with demo user and ads"
  remote_task :seed_db do
    puts "seeding db content"
    run "cd #{current_path} && bundle exec ./script/seed_db_content.rb"
  end
end
