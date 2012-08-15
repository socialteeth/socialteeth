class CurrencyError < StandardError
end

class String
  def is_currency?
    self.match(/^\$?\d+(\.\d{2})?$/)
  end

  def to_dollars
    raise CurrencyError, "#{self} is not a currency." unless self.is_currency?
    Integer(self.match(/^\$?(\d+)/)[1])
  end
end

class Integer
  def to_currency
    dollars = self / 100
    dollars = dollars.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse # Add commas
    "$#{dollars}"
  end
end
