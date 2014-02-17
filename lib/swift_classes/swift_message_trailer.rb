require_relative 'swift_line'

module SwiftClasses

  class SwiftMessageTrailer < SwiftLine
    def convert
      @fields[ :tag ] = 'trailer'
      @fields[ :footer ] = raw
    end
  end

end
