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

class Integer
  def to_currency
    dollars = self / 100
    cents = self % 100
    cents = "#{cents}0" if cents.to_s.size == 1
    "$#{dollars}.#{cents}"
  end
end
