require_relative 'swift_line'

module SwiftClasses

  class SwiftRelatedReference < SwiftLine
    def convert
      @fields[ :tag ] = '21'
      @fields[ :related_reference ] = @raw.slice( 4, 16 )
    end
  end
  
end
