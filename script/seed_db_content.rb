#!/usr/bin/env ruby-local-exec

require "bundler/setup"
require "pathological"
require "yaml"
require "lib/db"
require "lib/uploader"

admin_user = User.find(:email => "admin@socialteeth.org")
if admin_user.nil?
  admin_user = User.create(:name => "Admin User", :email => "admin@socialteeth.org", :password => "admin",
                           :permission => "admin", :votes => 100)
end

demo_user = User.find(:email => "demo@socialteeth.org")
if demo_user.nil?
  demo_user = User.create(:name => "Demo User", :email => "demo@socialteeth.org", :password => "demo",
                          :votes => 100)
end

if demo_user.ads.empty?
  ads_data = YAML.load_file("fixtures/demo.yml")["ads"]
  ads_data.each do |ad_data|
    ad = Ad.create(:title => ad_data["title"], :description => ad_data["description"],
        :user_id => demo_user.id, :goal => ad_data["goal"], :ad_type => ad_data["ad_type"],
        :about_submitter => ad_data["about_submitter"], :url => ad_data["url"],
        :deadline => Time.now + 60 * 60 * 24 * 30)
    File.open(ad_data["thumbnail_file"], "r") do |thumbnail|
      ad.thumbnail_url_base = Uploader.new.upload_ad_thumbnail(ad, thumbnail)
      ad.save
    end
  end
end

if demo_user.comments.empty?
  comments_data = YAML.load_file("fixtures/demo.yml")["comments"]
  comments_data.each do |comment_data|
    Comment.create(:user_id => demo_user.id, :text => comment_data["text"])
  end
end

if demo_user.discussions.empty?
  discussions_data = YAML.load_file("fixtures/demo.yml")["discussions"]
  discussions_data.each do |discussion_data|
    discussion = Discussion.create(:user_id => demo_user.id, :title => discussion_data["title"])
    Comment.each { |comment| DiscussionComment.create(:discussion_id => discussion.id, :comment_id => comment.id) }
  end
end
