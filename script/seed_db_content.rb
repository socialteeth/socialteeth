#!/usr/bin/env ruby-local-exec

require "bundler/setup"
require "pathological"
require "lib/db"

demo_user = User.find(:email => "demo@socialteeth.org")
if demo_user.nil?
  demo_user = User.create(:name => "Demo User", :email => "demo@socialteeth.org", :password => "demo")
end

if demo_user.ads.empty?
  description = " Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin congue pharetra orci in " +
    "egestas. Vestibulum sed orci est, at sollicitudin nunc. Phasellus vitae euismod lorem. Nulla " +
    "venenatis dignissim felis, vitae tincidunt erat egestas sit amet. In hac habitasse platea dictumst. " +
    "Quisque turpis purus, faucibus quis cursus et, gravida nec felis. Quisque lacinia malesuada risus a " +
    "dapibus."

  Ad.create(:title => "Demo User Ad", :description => description, :user_id => demo_user.id, :goal => 1000,
      :ad_type => "video", :url => "http://example.com", :thumbnail_url => "http://example.com/thumbnail.png",
      :deadline => Time.now + 60 * 60 * 24 * 30)
end
