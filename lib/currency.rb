class CurrencyError < StandardError
end

class String
  def is_currency?
    self.match(/^\d+(\.\d{2})?$/)
  end

  def to_dollars
    raise CurrencyError, "#{self} is not a currency." unless self.is_currency?
    self.match(/^\d+/)[0]
  end
end
