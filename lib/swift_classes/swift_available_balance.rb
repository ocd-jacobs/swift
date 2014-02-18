require 'bigdecimal'
require_relative 'swift_line'

module SwiftClasses

  class SwiftAvailableBalance < SwiftLine
    def convert
      raw = @raw.sub( /^:[^:]+:/, '' )
      @fields[ :tag ] = '64'
      @fields[ :d_c ] = raw.slice( 0, 1 )
      @fields[ :closing_date ] = raw.slice( 1, 6 )
      @fields[ :currency_code ] = raw.slice( 7, 3 )
      @fields[ :available_balance ] = BigDecimal.new( raw.slice( 10, 15 ).sub( ',', '.' ) )
    end
  end

end
