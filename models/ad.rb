require "opengraph"

class Ad < Sequel::Model
  many_to_one :user
  one_to_many :payments

  def thumbnail_url(options)
    # TODO: This should be a nicer default image, possibly with the socialteeth logo.
    return "" if self.thumbnail_url_base.nil?
    options = {
      :size => "original",
      :cropped => false
    }.merge(options)
    File.join(self.thumbnail_url_base, "thumbnail_#{options[:size]}#{options[:cropped] ? "_cropped" : ""}.png")
  end

  def video_embed_url
    begin
      movie = OpenGraph.fetch(self.url)
    rescue URI::InvalidURIError
      return ""
    end

    return "" unless movie

    url = URI.parse(movie.url)
    if url.host.include?("youtube")
      # http://www.youtube.com/watch?v=a1b2c3
      "http://www.youtube.com/embed/#{url.query.split("=")[1]}"
    elsif url.host.include?("vimeo")
      # http://vimeo.com/123456
      "http://player.vimeo.com/video/#{url.path.gsub("/", "")}"
    else ""
    end
  end
end
