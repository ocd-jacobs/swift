require_relative 'swift_line'

module SwiftClasses

  class SwiftMessageHeader < SwiftLine
    def convert
      @fields[ :tag ] = 'header'
      @fields[ :header ] = raw
    end
  end

end

