require 'bigdecimal'
require_relative 'swift_line'

module SwiftClasses

  class SwiftClosingBalance < SwiftLine
    def convert
      raw = @raw.sub( /^:[^:]+:/, '' )
      @fields[ :tag ] = '62'
      @fields[ :d_c ] = raw.slice( 0, 1 )
      @fields[ :closing_date ] = raw.slice( 1, 6 )
      @fields[ :currency_code ] = raw.slice( 7, 3 )
      @fields[ :closing_balance ] = BigDecimal.new( raw.slice( 10, 15 ) )
    end
  end

end
