module SwiftClasses
  class SwiftStatementLine < SwiftLine
    def process_non_compliant
      description = @raw_descriptions[ 0 ].sub( /^:86: ?/, '' )
      
      case description
      when /^\d\d\./ then bank_account_begin     # regel begint met twee cijfers en een punt
        
#      when /^\d+/                                               # regel begint met cijfer
      when /^\w\w\d\d\w\w/ then iban_begin       # regel begnt met IBAN nummer
      when /^GIRO/ then giro_account_begin       # regel begint met GIRO
#      when /^ZEROBALANCING/
#      when /^NONREF/
#      when /^ONZE REF/
#      when /^COR ST2/
#      when /^[A-Z]/                                          # regel begint met letter
#      when /^\/PREF\//                                       # regel begint met /PREF/
#      else

      end
    end

    def bank_account_begin
      description_field = @raw_descriptions[ 0 ].sub( /^:86: ?/, '' )
      account_begin( description_field )
    end

    def giro_account_begin
      description_field = @raw_descriptions[ 0 ].sub( /^:86: ?GIRO +/, '' )
      account_begin( description_field )
    end

    def account_begin( description_field )
      @fields[ :iban ] = description_field.slice(/^[^ ]+/)
      @fields[ :name ] = description_field.sub( /^[^ ]+/, '' ).strip

      start_remi = 3

      if @fields[ :name ].strip == ''
        @fields[ :name ] = @raw_descriptions[ 1 ].strip
        start_remi = 4
      else
        if description_field.strip.length - description_field.strip.squeeze( ' ' ).length >= 15
          start_remi = 2
        end
      end
      
      @fields[ :remi ] = ''
      @raw_descriptions[ start_remi .. -1 ].each do | description |
        @fields[ :remi ] << description
      end
      
      @fields[ :remi ].strip!
      @fields[ :remi ].squeeze!( ' ' )
    end
    
    def iban_begin
      description_string = get_description.squeeze( ' ' ).sub( /^:86: ?/, '' )

      process_old_swift_format( :iban , description_string )
      process_old_swift_format( :name , description_string )
      process_old_swift_format( :remi , description_string )
      process_old_swift_format( :eref , description_string )
      process_old_swift_format( :ordp_id , description_string )

      @fields[ :benm_id ] = description_string.slice( /^[^)]+/ ).strip
    end

    def process_old_swift_format( key, description_string )
      @fields[ key ] = description_string.slice( /^[^)]+/ ).strip
      description_string.sub!( /^[^)]*\) ?\( ?/, '' )      
    end
    
  end
end
