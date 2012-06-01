#!/usr/bin/env ruby-local-exec

require "bundler/setup"
require "pathological"
require "yaml"
require "lib/db"
require "lib/uploader"

demo_user = User.find(:email => "demo@socialteeth.org")
if demo_user.nil?
  demo_user = User.create(:name => "Demo User", :email => "demo@socialteeth.org", :password => "demo")
end

if demo_user.ads.empty?
  ads_data = YAML.load_file("fixtures/demo.yml")["ads"]
  ads_data.each do |ad_data|
    ad = Ad.create(:title => ad_data["title"], :description => ad_data["description"],
        :user_id => demo_user.id, :goal => ad_data["goal"], :ad_type => ad_data["ad_type"],
        :about_submitter => ad_data["about_submitter"], :url => ad_data["url"],
        :deadline => Time.now + 60 * 60 * 24 * 30)
    File.open(ad_data["thumbnail_file"], "r") do |thumbnail|
      ad.thumbnail_url = Uploader.new.upload_ad_thumbnail(ad, thumbnail)
      ad.save
    end
  end
end
