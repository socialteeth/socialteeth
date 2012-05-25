#!/usr/bin/env ruby-local-exec

require "bundler/setup"
require "pathological"
require "lib/db"

demo_user = User.find(:email => "demo@socialteeth.org")
if demo_user.nil?
  demo_user = User.create(:name => "Demo User", :email => "demo@socialteeth.org", :password => "demo")
end
