# ******************************************************************************
# File    : SWIFT_STATEMENT_LINE.RB
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
# Notes   : Class representing a Swift MT940 statement line (tag :61:)
# ******************************************************************************

require 'bigdecimal'
require_relative 'swift_line'
require_relative 'swift_non_compliant'

module SwiftClasses

  class SwiftStatementLine < SwiftLine
    def initialize( swift_61_string, swift_61_extra_string = ' ', swift_86_array = [] )

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

      initialize_transaction_fields

      sepa_codes = ' /PREF/ /IBAN/ /EREF/ /MARF/ '
      match_data = @raw_descriptions[ 0 ].match( /^:86: *\/([A-Z]+)\// )

      unless match_data.nil?
        sepa_compliant = sepa_codes.include? match_data[ 1 ]
      else
        sepa_compliant = false
      end

      if sepa_compliant
        process_descriptions
        adjust_owner_reference
      else
        process_non_compliant
      end

      text_86
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
      BigDecimal.new( line.slice!( /^\d+,\d\d/).sub( ',', '.') )
    end

    def transaction_type( line )
      line.slice!( 0, 4 )
    end
    
    def owner_reference( line )
      line.slice!( /^[^\/]*/ )
    end

    def servicing_reference( line )
      if line[ 0 ] == '/'
        line.slice!( /[^\/]*$/ )
      else
        ' '
      end
    end

    def further_reference
      if @raw_extra.nil? || @raw_extra.empty?
        ' '
      else
        @raw_extra
      end
    end

    def process_descriptions
      description_string = get_description
      
      transaction_fields = [
                            [ '/IBAN/'       , -1 , ' ', :iban ],
                            [ '/BIC/'        , -1 , ' ', :bic ],
                            [ '/NAME/'       , -1 , ' ', :name ],
                            [ '/RTRN/'       , -1 , ' ', :rtrn ],
                            [ '/REMI/'       , -1 , ' ', :remi ],
                            [ '/EREF/'       , -1 , ' ', :eref ],
                            [ '/ORDP//ID/'   , -1 , ' ', :ordp_id ],
                            [ '/BENM//ID/'   , -1 , ' ', :benm_id ],
                            [ '/UDTR/'       , -1 , ' ', :udtr ],
                            [ '/UCRD/'       , -1 , ' ', :ucrd ],
                            [ '/PURP/'       , -1 , ' ', :purp ],
                            [ '/FX/'         , -1 , ' ', :fx ],
                            [ '/PREF/'       , -1 , ' ', :pref ],
                            [ '/NRTX/'       , -1 , ' ', :nrtx ],
                            [ '/IREF/'       , -1 , ' ', :iref ],
                            [ '/MARF/'       , -1 , ' ', :marf ],
                            [ '/SVCL/'       , -1 , ' ', :svcl ],
                            [ '/BENM//NAME/' , -1 , ' ', :benm_name ],
                            [ '/CSID/'       , -1 , ' ', :csid ]
                           ]

      get_field_values( transaction_fields, description_string )
      put_field_values( transaction_fields )
    end

    def get_description
      description_string = ''
      @raw_descriptions.each do |description|
        description_string << description.chomp
      end

      description_string.squeeze(' ')
    end

    def get_field_values( transaction_fields, description_string )
      transaction_fields.each do | field |
        
        field[ 1 ] = description_string.index( field[ 0 ] )
        field[ 1 ] ||= -1

        # /NAME/ also found in key /BENM//NAME/ !!!
        if field[ 0 ] == '/NAME/'
          if description_string =~ /\/BENM\/\/NAME\//
            field[ 1 ] = -1
          end
        end
      end

      transaction_fields.sort! {| elem_1, elem_2 | elem_1[ 1 ] <=> elem_2[ 1 ] }

      0.upto( transaction_fields.length - 2) do | index |
        if transaction_fields[ index ][ 1 ] > -1
          transaction_fields[ index ][ 2 ] = description_string[ ( transaction_fields[ index ][ 1 ] + transaction_fields[ index ][ 0 ].length ) ... ( transaction_fields[ index + 1 ][ 1 ] ) ]
        end
      end

      index = transaction_fields.length - 1
      transaction_fields[ index ][ 2 ] = description_string[ ( transaction_fields[ index ][ 1 ] + transaction_fields[ index ][ 0 ].length ) .. -1 ]
    end

    def put_field_values( transaction_fields )
      transaction_fields.each do | field |
        field[ 2 ].strip! unless field[ 2 ] == ' '
        @fields[ field[ 3 ] ] = field[ 2 ]
      end
    end

    def adjust_owner_reference
      if @fields[ :owner_reference ] == 'EREF'
        @fields[ :owner_reference ] = @fields[ :eref ]
      end

      if @fields[ :owner_reference ] == 'PREF'
        @fields[ :owner_reference ] = @fields[ :pref ]
      end
    end

    def initialize_transaction_fields
      transaction_fields = [
                            :iban,
                            :bic,
                            :name,
                            :rtrn,
                            :remi,
                            :eref,
                            :ordp_id,
                            :benm_id,
                            :udtr,
                            :ucrd,
                            :purp,
                            :fx,
                            :pref,
                            :nrtx,
                            :iref,
                            :marf,
                            :svcl,
                            :benm_name,
                            :csid,
                            :text_86
                           ]

      transaction_fields.each do | field |
        @fields[ field ] = ' '
      end
    end

    def text_86
      description_string = ''
      @raw_descriptions.each do |description|
        description_string << '_' + description.chomp + '_'
      end

      @fields[ :text_86 ] = description_string.squeeze(' ').sub( /^:86: ?/, '' )
    end
    
  end

end

