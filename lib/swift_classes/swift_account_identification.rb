require_relative 'swift_line'

module SwiftClasses

  class SwiftAccountIdentification < SwiftLine
    def convert
      @fields[ :tag ] = '25'
      @fields[ :account_identification ] = @raw.slice( 4, 35 )
    end
  end

end

