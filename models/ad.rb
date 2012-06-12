class Ad < Sequel::Model
  many_to_one :user

  def thumbnail_url(options)
    options = {
      :size => "original",
      :cropped => false
    }.merge(options)
    File.join(self.thumbnail_url_base, "thumbnail_#{options[:size]}#{options[:cropped] ? "_cropped" : ""}.png")
  end
end
