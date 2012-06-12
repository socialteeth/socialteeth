require "fileutils"
require "image_science"
require "aws/s3"
require "pathological"
require "environment"

class Uploader
  def upload_ad_thumbnail(ad, thumbnail_file)
    if defined?(S3_BUCKET)
      # Uploads thumbnails to S3_BUCKET/ad/:public_id/
      establish_s3_connection!
      upload_ad_thumbnails_to_s3(ad, thumbnail_file)
    else
      # Uploads thumbnails to socialteeth/public/uploads/ad/:public_id/
      upload_ad_thumbnails_to_filesystem(ad, thumbnail_file)
    end
  end

  private

  # TODO: Refactor common logic between s3 and filesystem uploads.
  def upload_ad_thumbnails_to_s3(ad, thumbnail_file)
    ad_directory = "/ad/#{ad.public_id}"

    write_to_s3("#{ad_directory}/thumbnail_original.png", thumbnail_file)
    thumbnail_file.rewind

    tmp_thumbnail = "/tmp/socialteeth/uploads/ad/#{ad.public_id}/thumbnail_original.png"
    write_to_filesystem(tmp_thumbnail, thumbnail_file)

    [200, 300].each do |size|
      thumbnail_destination = File.join(ad_directory, "thumbnail_#{size}.png")
      thumbnail_cropped_destination = File.join(ad_directory, "thumbnail_#{size}_cropped.png")
      thumbnail_tmp_destination = File.join(File.dirname(tmp_thumbnail), "thumbnail_#{size}.png")
      thumbnail_tmp_cropped_destination = File.join(File.dirname(tmp_thumbnail), "thumbnail_#{size}_cropped.png")

      ImageScience.with_image(tmp_thumbnail) do |image|
        image.thumbnail(size) do |thumb|
          thumb.save(thumbnail_tmp_destination)
          write_to_s3(thumbnail_destination, File.open(thumbnail_tmp_destination))
        end
        image.cropped_thumbnail(size) do |thumb|
          thumb.save(thumbnail_tmp_cropped_destination)
          write_to_s3(thumbnail_cropped_destination, File.open(thumbnail_tmp_cropped_destination))
        end
      end
    end

    FileUtils.rm_rf(File.dirname(tmp_thumbnail))

    "https://s3.amazonaws.com/#{S3_BUCKET}/ad/#{ad.public_id}"
  end

  def upload_ad_thumbnails_to_filesystem(ad, thumbnail_file)
    uploads_root = File.join(File.dirname(File.dirname(__FILE__)), "public", "uploads")
    ad_directory = File.join(uploads_root, "ad", "#{ad.public_id}")
    thumbnail_original_destination = File.join(ad_directory, "thumbnail_original.png")
    write_to_filesystem(thumbnail_original_destination, thumbnail_file)

    [200, 300].each do |size|
      thumbnail_destination = File.join(ad_directory, "thumbnail_#{size}.png")
      thumbnail_cropped_destination = File.join(ad_directory, "thumbnail_#{size}_cropped.png")

      ImageScience.with_image(thumbnail_original_destination) do |image|
        image.thumbnail(size) { |thumb| thumb.save(thumbnail_destination) }
        image.cropped_thumbnail(size) { |thumb| thumb.save(thumbnail_cropped_destination) }
      end
    end

    "/#{File.dirname(thumbnail_original_destination).split("/").drop_while do |directory|
      directory != "uploads"
    end.join("/")}"
  end

  def establish_s3_connection!
    unless defined?(AMAZON_ACCESS_KEY_ID) && defined?(AMAZON_SECRET_ACCESS_KEY)
      raise "Missing AMAZON_ACCESS_KEY_ID or AMAZON_SECRET_ACCESS_KEY"
    end
    unless AWS::S3::Base.connected?
      AWS::S3::Base.establish_connection!(:access_key_id => AMAZON_ACCESS_KEY_ID,
          :secret_access_key => AMAZON_SECRET_ACCESS_KEY)
    end
  end

  def write_to_s3(path, file)
    raise "S3_BUCKET undefined" unless defined?(S3_BUCKET)
    AWS::S3::S3Object.store(path, file, S3_BUCKET, :access => :public_read)
  end

  def write_to_filesystem(path, file)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "w") do |destination_file|
      while block = file.read(65536)
        destination_file.print block
      end
    end
  end
end
