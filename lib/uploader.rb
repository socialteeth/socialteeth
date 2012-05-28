require "fileutils"

class Uploader
  UPLOAD_URL_BASE = File.join(File.dirname(File.dirname(__FILE__)), "public", "uploads")

  # Uploads a file to socialteeth/public/uploads.
  # TODO: This should upload to S3 in production and the filesystem in development.
  def upload_ad_thumbnail(ad, thumbnail_file)
    ad_directory = FileUtils.mkdir_p(File.join(UPLOAD_URL_BASE, "ads", "#{ad.id}")).first
    thumbnail_destination = File.join(ad_directory, "thumbnail")
    File.open(thumbnail_destination, "w") do |destination_file|
      while block = thumbnail_file.read(65536)
        destination_file.print block
      end
    end
    "/#{thumbnail_destination.split("/").drop_while { |directory| directory != "uploads"}.join("/")}"
  end
end
