# ******************************************************************************
# File    : SWIFT_NON_COMPLIANT.RB
# ------------------------------------------------------------------------------
# Author  : J.M. Jacobs
# Date    : 03 March 2014
# Version : 1.0
#
# (C) 2014: This program is free software: you can redistribute it and/or modify
#           it under the terms of the GNU General Public License as published by
#           the Free Software Foundation, either version 3 of the License, or
#           (at your option) any later version.
#
#           This program is distributed in the hope that it will be useful,
#           but WITHOUT ANY WARRANTY; without even the implied warranty of
#           MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#           GNU General Public License for more details.
#
#           You should have received a copy of the GNU General Public License
#           along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Notes   : Extention of the SwiftStatementLine class. Contains fuctionality
#           for handeling statement line descriptions (tag :86:) that do not
#           comply with standard Swift MT940 layouts.
# ******************************************************************************

module SwiftClasses
  class SwiftStatementLine < SwiftLine
    def process_non_compliant
      description = @raw_descriptions[ 0 ].sub( /^:86: ?/, '' )
      
      case description
      when /^\d\d\./ then bank_account_begin                # line starts with two nunbers follwed by a dot: bank account
      when /^[A-Z]{2}\d{2}[A-Z]{2}/ then pre_2014_sepa      # line starts with a IBAN number
      when /^[A-Z]{2}\d{2}/ then foreign_account            # line probably starts with a foreign bank account number
      when /^GIRO/ then giro_account_begin
      when /^ZEROBALANCING/ then zero_balancing
      when /^TOTAAL BETALINGEN/ then batch_payment
      when /^GESTORT DOOR/ then deposit
      when /^NONREF/ then batch_payment
      when /^\d{16}/ then payments_received                 # line starts with 16 digits
      when /^COR +ST2/ then sepa_payments_received
      when /^ONZE REF/ then invoice
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
      description_string = description_squeeze

      description_values = description_string.split( ')(')
      keys_end = description_values.length

      keys = [ :iban, :name, :remi, :eref, :ordp_id, :benm_id ]
      description_values.length > keys.length ? keys.length : description_values.length

      keys_end.times do | index |
        description_values[index] = ' ' if description_values[index].nil?
        @fields[ keys[ index ] ] = description_values[ index ].strip
        @fields[ keys[ index ] ] = ' ' if @fields[ keys[ index ] ].empty?
      end
    end

    def zero_balancing
      description_string = description_squeeze

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
      description_string = description_squeeze

      description_values = description_string.split( ')(')
      keys_end = description_values.length

      keys = [ :iban, :name, :remi, :eref, :ordp_id ]
      description_values.length > keys.length ? keys.length : description_values.length

      keys_end.times do | index |
        description_values[index] = ' ' if description_values[index].nil?
        @fields[ keys[ index ] ] = description_values[ index ].strip
        @fields[ keys[ index ] ] = ' ' if @fields[ keys[ index ] ].empty?
      end
    end

    def no_specification
      description_string = description_squeeze
      @fields[ :remi ] = description_string
    end
    
    def batch_payment
      no_specification
    end

    def invoice
      description_string = description_squeeze

      @fields[ :iban ] = description_string.slice(/[A-Z]{2}\d{2}[A-Z]{2,}\d{8,}/)
      @fields[ :iban ] = description_string.slice(/[A-Z]{2}\d{8,}/) if @fields[ :iban ].nil?
      @fields[ :iban ] = ' ' if @fields[ :iban ].nil?

      if md = description_string.match( /^.*BEGUNST.1([^\d]+)/ )
      elsif md = description_string.match( /^.*BEGUNST.([^\/]+)/ )
      elsif md = description_string.match( /^.*OPDRACHTGEVER\d\/([^\/]+)/ )
      elsif md = description_string.match( /^.*OPDRACHTGEVER([^\/]+)/ )
      end

      @fields[ :name ] = md[1] if md
    end
    
    def deposit
      no_specification
    end

    def description_squeeze
      get_description.squeeze( ' ' ).sub( /^:86: ?/, '' )
    end
  end
end
