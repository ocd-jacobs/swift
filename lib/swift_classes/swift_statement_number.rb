require_relative 'swift_line'

module SwiftClasses

  class SwiftStatementNumber < SwiftLine
    def convert
      raw = @raw.sub( /^:[^:]+:/, '' )
      @fields[ :tag ] = '28'
      @fields[ :statement_number ] = raw.slice( /^\d+/ )

      if raw =~ /\//
        @fields[ :sequence_number ] = raw.slice( /[^\/]+$/ )
      else
        @fields[ :sequence_number ] = ' ' 
      end
    end
  end

end

