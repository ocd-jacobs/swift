module SwiftClasses
  class SwiftStatementLine < SwiftLine
    def process_non_compliant
      description = @raw_descriptions[ 0 ].sub( /^:86: ?/, '' )
      
      case description
      when /^\d\d\./ then bank_account_begin                # regel begint met twee cijfers en een punt
      when /^[A-Z]{2}\d{2}[A-Z]{2}/ then pre_2014_sepa      # regel begnt met IBAN nummer
      when /^[A-Z]{2}\d{2}/ then foreign_account            # regel beterft waarschijnlijk een buitenlands rekening nummer
      when /^GIRO/ then giro_account_begin                  # regel begint met GIRO
      when /^ZEROBALANCING/ then zero_balancing
      when /^TOTAAL BETALINGEN/ then batch_payment
      when /^GESTORT DOOR/ then deposit
      when /^NONREF/ then batch_payment
      when /^\d{16}/ then payments_received
      when /^COR +ST2/ then sepa_payments_received
      else
        no_specification
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

      remi_start = 3       # account and name on the same line - 2 address entries
      
      if @fields[ :name ].strip == ''
        @fields[ :name ] = @raw_descriptions[ 1 ].strip
        remi_start = 4     # account and name on different lines - 2 address entries
      else
        if description_field.strip.length - description_field.strip.squeeze( ' ' ).length >= 15
          remi_start = 2   # account and name on the same line - 1 address entry
        end
      end

      line_count = @raw_descriptions.size

      case line_count
      when 2 then remi_start = 1     # account and name on the same line - no address entries
      when 3 then remi_start = 2     # account and name on the same line - 2 address entries
      end

      @fields[ :remi ] = ''
      @raw_descriptions[ remi_start .. -1 ].each do | description |
        @fields[ :remi ] << description
      end
      
      @fields[ :remi ].strip!
      @fields[ :remi ].squeeze!( ' ' )
    end
    
    def pre_2014_sepa

      description_string = get_description.squeeze( ' ' ).sub( /^:86: ?/, '' )

      md = description_string.match(/(.+)\)\((.+)\)\((.+)\)\((.+)\)\(([^)]+)\)\(([^)]+)/)
      keys_end = 6
      
      unless md
        md = description_string.match(/(.+)\)\((.+)\)\((.+)\)\((.+)\)\(([^)]+)/)
        keys_end = 5
      end

      keys = [ nil, :iban, :name, :remi, :eref, :ordp_id, :benm_id ]

      1.upto( keys_end ) do | index |
        md[index] = ' ' if md[index].nil?
        @fields[ keys[ index ] ] = md[ index ].strip
        @fields[ keys[ index ] ] = ' ' if @fields[ keys[ index ] ].empty?
      end
    end

    def zero_balancing
      description_string = get_description.squeeze( ' ' ).sub( /^:86: ?/, '' )

      md = description_string.match( /AND (\d+)/ )
      
      @fields[ :iban ] = md[ 1 ]
      @fields[ :remi ] = description_string
      
    end

    def payments_received
      remi = @raw_descriptions.clone
      remi[0].sub!( /^:86: ?/, '' )

      if @raw_descriptions[ 1 ][ 0 ] == '/'
        md = @raw_descriptions[ 1 ].match( /^\/([^ ]+) +([^ ].*)$/ )

        @fields[ :iban ] = md[ 1 ]
        @fields[ :name ] = md[ 2 ]

        remi.delete_at( 1 )
      else
        @fields[ :iban ] = @raw_descriptions[ 2 ][ 1 .. -1 ]
        @fields[ :name ] = @raw_descriptions[ 3 ]

        remi.delete_at( 3 )
        remi.delete_at( 2 )
      end

      @fields[ :remi ] = ''
      remi.each do | description |
        @fields[ :remi ] << description.squeeze( ' ' )
      end
    end

    def sepa_payments_received
      raw_original = @raw_descriptions.clone
      @raw_descriptions.delete_at( 0 )

      process_descriptions
      adjust_owner_reference

      @raw_descriptions = raw_original
    end

    def foreign_account     
      description_string = get_description.squeeze( ' ' ).sub( /^:86: ?/, '' )

      md = description_string.match(/(.+)\)\((.+)\)\((.+)\)\((.+)\)\(([^)]+)/)

      keys = [ nil, :iban, :name, :remi, :eref, :ordp_id ]

      1.upto( 5 ) do | index |
        @fields[ keys[ index ] ] = md[ index ].strip
        @fields[ keys[ index ] ] = ' ' if @fields[ keys[ index ] ].empty?
      end
    end

    def no_specification
      description_string = get_description.squeeze( ' ' ).sub( /^:86: ?/, '' )
      @fields[ :remi ] = description_string
    end
    
    def batch_payment
      no_specification
    end

    def deposit
      no_specification
    end
  end
end
