module Abstractor
  module Utility
    def self.dehumanize(target)
      result = target.to_s.dup
      result.downcase.gsub(/ +/,'_')
    end
  end
end