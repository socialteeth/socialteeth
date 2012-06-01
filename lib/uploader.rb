require "fileutils"
require "image_science"

class Uploader
  UPLOAD_URL_BASE = File.join(File.dirname(File.dirname(__FILE__)), "public", "uploads")

  # Uploads a file to socialteeth/public/uploads.
  # TODO: This should upload to S3 in production and the filesystem in development.
  def upload_ad_thumbnail(ad, thumbnail_file)
    ad_directory = FileUtils.mkdir_p(File.join(UPLOAD_URL_BASE, "ad", "#{ad.id}")).first
    thumbnail_original_destination = File.join(ad_directory, "thumbnail_original.png")
    File.open(thumbnail_original_destination, "w") do |destination_file|
      while block = thumbnail_file.read(65536)
        destination_file.print block
      end
    end

    [200, 300].each do |size|
      thumbnail_destination = File.join(ad_directory, "thumbnail_#{size}.png")
      thumbnail_cropped_destination = File.join(ad_directory, "thumbnail_#{size}_cropped.png")

      ImageScience.with_image(thumbnail_original_destination) do |image|
        image.thumbnail(size) { |thumb| thumb.save(thumbnail_destination) }
        image.cropped_thumbnail(size) { |thumb| thumb.save(thumbnail_cropped_destination) }
      end
    end

    "/#{thumbnail_original_destination.split("/").drop_while { |directory| directory != "uploads"}.join("/")}"
  end
end
