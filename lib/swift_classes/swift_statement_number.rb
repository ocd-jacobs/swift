require_relative 'swift_line'

module SwiftClasses

  class SwiftStatementNumber < SwiftLine
    def convert
      raw = @raw.sub( /^:[^:]+:/, '' )
      @fields[ :tag ] = '28'
      @fields[ :statement_number ] = raw.slice( /^\d+/ )
      @fields[ :sequence_number ] = sequence_number( raw )
    end

    def sequence_number( raw )
      if raw =~ /\//
        raw.slice( /[^\/]+$/ )
      else
        ' ' 
      end
    end
    
  end

end

