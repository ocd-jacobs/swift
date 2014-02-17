require 'bigdecimal'
require_relative 'swift_line'

module SwiftClasses

  class SwiftStatementLine < SwiftLine
    def initialize( swift_61_string, swift_61_extra_string, swift_86_array )

      # ??????????????????????????????????????????????????????????????????????????????
      # Waarom moeten de instance vaiabelen VOOR de call naar super worden aangemaakt?
      # Als ze na super worden aangemaakt verdwijnen ze na afloop van initialize!
      # ??????????????????????????????????????????????????????????????????????????????
      
      @raw_extra = swift_61_extra_string
      @raw_descriptions = swift_86_array
      super( swift_61_string )
    end
    
    def convert
      line = @raw[ 4 .. -1 ]

      @fields[ :tag ] = '61'
      @fields[ :value_date ]          = value_date( line )
      @fields[ :entry_date ]          = entry_date( line )
      @fields[ :d_c ]                 = d_c( line )      
      @fields[ :funds_code ]          = funds_code( line )     
      @fields[ :transaction_amount ]  = transaction_amount( line )     
      @fields[ :transaction_type ]    = transaction_type( line )      
      @fields[ :owner_reference ]     = owner_reference( line )      
      @fields[ :servicing_reference ] = servicing_reference( line )

      @fields[ :further_reference ]   = further_reference

      process_descriptions
    end

    def value_date( line )
      line.slice!( 0, 6 )
    end
    
    def entry_date( line )
      if line[ 0 ] =~ /\d/
        # Entry date present
        entry_date  = line.slice!( 0, 4 )
      else
        # No entry date present
        entry_date = ' '
      end

      entry_date
    end

    def d_c( line )
      if line =~ /^R[C|D]/
        d_c = line.slice!( 0, 2 )
      else
        d_c = line.slice!( 0,1 )
      end

      d_c
    end
    
    def funds_code( line )
      if line =~ /^\d/
        funds_code = ' '
      else
        funds_code = line.slice!( 0 )
      end
    end

    def transaction_amount( line )
      BigDecimal.new( line.slice!( /^\d+,\d\d/) )
    end

    def transaction_type( line )
      line.slice!( 0, 4 )
    end
    
    def owner_reference( line )
      line.slice!( /^[^\/]*/ )
    end

    def servicing_reference( line )
      if line[ 0 ] = '/'
        line.slice!( /[^\/]*$/ )
      else
        ' '
      end
    end

    def further_reference
      if @raw_extra.nil?
        ' '
      else
        @raw_extra
      end
    end

    def process_descriptions
      description_string = ''
      @raw_descriptions.each do |description|
        description_string << description.chomp
      end
      description_string.squeeze(' ')
      description_string.slice!( /^:86:/ )

      while field = description_string.slice!( /\/\w+\/[^\/]+/ )
        field = field[ 1 ..-1 ]
        key = field.slice!( /^\w+/ ).to_sym
        value = field[ 1 ..-1 ]
        @fields[ key ] = value
      end
    end

  end

end

