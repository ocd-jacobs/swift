require_relative 'swift_line'

module SwiftClasses

  class SwiftAccountNumber < SwiftLine
    def convert
      @fields[ :tag ] = '25'
      @fields[ :account_number ] = @raw.slice( 4, 35 )
    end
  end

end

