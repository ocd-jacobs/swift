require_relative 'swift_line'

module SwiftClasses

  class SwiftTransactionReference < SwiftLine
    def convert
      @fields[ :tag ] = '20'
      @fields[ :transaction_reference ] = @raw.slice( 4, 16 )
    end
  end

end

