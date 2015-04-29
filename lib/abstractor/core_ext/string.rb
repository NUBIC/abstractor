class Regexp
  NUMERIC = Regexp.union(%r{^-?\d{1,3}(,\d{3}|\d+)*(\.\d+)*$},
    %r{^\(?\d{1,3}(,\d{3}|\d+)*(\.\d+)*\)?$})
end

class String
  def to_boolean
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  # Like #index but returns a Range.
  #
  #   "This is a test!".range('test')  #=> (10..13)
  #
  # CREDIT: Trans

  def range(pattern, offset=0)
    unless Regexp === pattern
      pattern = Regexp.new(Regexp.escape(pattern.to_s))
    end
    string = self[offset..-1]
    if md = pattern.match(string)
      return (md.begin(0)+offset)..(md.end(0)+offset-1)
    end
    nil
  end

  # Like #index_all but returns an array of Ranges.
  #
  #   "abc123abc123".range_all('abc')  #=> [0..2, 6..8]
  #
  # TODO: Add offset ?
  #
  # CREDIT: Trans

  def range_all(pattern, reuse=false)
    r = []; i = 0
    while i < self.length
      rng = range(pattern, i)
      if rng
        r << rng
        if reuse
          i +=1
        else
          i = rng.end + 1
        end
      else
        break
      end
    end
    r.uniq
  end

  # Returns an array of ranges mapping
  # the characters per line.
  #
  #   "this\nis\na\ntest".range_of_line
  #   #=> [0..4, 5..7, 8..9, 10..13]
  #
  # CREDIT: Trans

  def range_of_line
    offset=0; charmap = []
    each_line do |line|
      charmap << (offset..(offset + line.length - 1))
      offset += line.length
    end
    charmap
  end

  def numeric?
    match(Regexp::NUMERIC) != nil
  end

  def integer?
    begin
      Integer(self)
      self
    rescue ArgumentError => e
      nil
    end
  end

  def date?
    begin
      d = Date.parse(self)
    rescue ArgumentError => e
      nil
    end
  end

  def ssn?
    if  (integer? && length == 9)
      self
    elsif ((self =~ /[0-9]{3}-[0-9]{2}-[0-9]{4}/ ) == 0)
      self.gsub('-','')
    else
      nil
    end
  end
end