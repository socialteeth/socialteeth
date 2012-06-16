class Ad < Sequel::Model
  many_to_one :user

  def thumbnail_url(options)
    # TODO: This should be a nicer default image, possibly with the socialteeth logo.
    return "" if self.thumbnail_url_base.nil?
    options = {
      :size => "original",
      :cropped => false
    }.merge(options)
    File.join(self.thumbnail_url_base, "thumbnail_#{options[:size]}#{options[:cropped] ? "_cropped" : ""}.png")
  end
end
