# Source   : swift_converter.rb
# *********************************************************************************
# Auteur   : J.M. Jacobs
# Copyright: 2013 J.M. Jacobs
#
#            This program is free software: you can redistribute it and/or modify
#            it under the terms of the GNU General Public License as published by
#            the Free Software Foundation, either version 3 of the License, or
#            (at your option) any later version.
#
#            This program is distributed in the hope that it will be useful,
#            but WITHOUT ANY WARRANTY; without even the implied warranty of
#            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#            GNU General Public License for more details.
#
#            You should have received a copy of the GNU General Public License
#            along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# Datum    : 4 Januari 2013
# Ruby     : 2.0
#
# Notities : Klasse declaratie Swift MT940 bestand Royal Bank of Scotland
# *********************************************************************************

require 'bigdecimal'

class SwiftConverter
  def initialize(swift_file_object)
    if swift_file_object.class == File
      @swift_file = swift_file_object
    else
      raise RuntimeError, 'Not a valid File object'
    end

    @swift_array = []
    @current_tag = 'XX'
  end

  def swift_array
    if @swift_array.empty?
      to_a
    end

    @swift_array
  end
  
  def to_a
    @swift_file.each do |  line |
      process_swift_line( line )
    end
  end

  def process_swift_line( file_line )
    line = file_line.chomp
    
    if line =~ /^{\d/
      @swift_array << [ :header, { header: line } ]
    elsif line =~ /^-}/
      @swift_array << [ :footer, { footer: line } ]
    else
      tag = line.slice( /^:\d\d[A-Z]?:/ )

      if tag
        @current_tag = tag.gsub( ':', '' )
        @swift_array << parse_swift_line( line )
      else
        parse_swift_extra ( line )
      end

    end
  end

  def parse_swift_line( line )
    case @current_tag
    when '20' then tag_20( line )
    when '25' then tag_25( line )
    when '28C' then tag_28C( line )
    when '60F' then tag_60F( line )
    when '61' then tag_61( line )
    when '62F' then tag_62F( line )
    when '64' then tag_64( line )
    when '86' then tag_86( line )
    else [ @current_tag, { line: line } ]
    end
  end

  def tag_20( line )
    [ :tag_20 , { transaction_reference_number: line.slice( 4, 16 ) } ]
  end

  def tag_25( line )
    [ :tag_25 , { account_number: line.slice( 4, 35 ) } ]
  end

  def tag_28C( line )
    line = line.slice( 5, 11 )
    statement = line.slice( /^\d+/ )
    sequence = line.slice( /\d+$/ )
    [ :tag_28C , { statement_number: statement, sequence_number: sequence } ]
  end

  def tag_60F( line )
    [ :tag_60F,
      { d_c: line.slice( 5, 1 ),
        date: line.slice( 6, 6 ),
        currency_code: line.slice( 12, 3),
        opening_balance: line.slice( 15, 15)
      }
    ]
  end

  def tag_61( line )
    value_date = line.slice( 4, 6 )

    if line.slice( 11, 1 ) =~ /\d/
      # Entry date present
      entry_date = line.slice( 10, 4 )
      line = line[ 14 .. -1 ]
    else
      # No entry date present
      entry_date = ' '
      line = line[ 10 .. -1 ]
    end

    if line =~ /^[A-Z]\d/
      d_c = line.slice( 0, 1 )
      funds_code = ' '
      line = line[ 1 .. -1 ]
    elsif line =~ /^[A-Z][A-Z][A-Z]\d/
      d_c = line.slice( 0, 2 )
      funds_code = line.slice( 2,1 )
      line = line[ 3 .. -1]
    elsif
      if line =~ /^RC|^RD/
        d_c = line.slice( 0, 2 )
        funds_code = ' '
      else
        d_c = line.slice( 0, 1 )
        funds_code = line.slice( 1, 1 )
      end

      line = line[ 2 .. -1 ]
    end

    amount_text = line.slice( /^\d+,\d\d/ ) 
    line = line[ amount_text.length .. -1 ]
    amount = BigDecimal.new( amount_text )

    transaction_type = line.slice( 0, 4 )
    line = line[ 4 .. -1 ]

    owner_reference = line.slice( /^[^\/]+/ )

    if line =~ /\//
      line = line.gsub( /^.*\//, '' )
      servicing_reference = line.slice( /[^\/]+$/ )
    else
      servicing_reference = ' '
    end

    [ :tag_61, 
      { value_date: value_date,
        entry_date: entry_date,
        d_c: d_c,
        funds_code: funds_code,
        transaction_amount: amount,
        transaction_type: transaction_type,
        owner_reference: owner_reference,
        servicing_reference: servicing_reference,
        further_reference: ''
     }
    ]
  end

  def tag_62F( line )
    [ :tag_62F,
      { d_c: line.slice( 5, 1 ),
        entry_date: line.slice( 6, 6 ),
        currency_code: line.slice( 12, 3 ),
        closing_balance: line.slice( /\d+,\d\d$/ )        
      }
    ]
  end

  def tag_64( line )  
    [ :tag_64,
      { d_c: line.slice( 4, 1 ),
        entry_date: line.slice( 5, 6 ),
        currency_code: line.slice( 11, 3 ),
        available__balance: line.slice( /\d+,\d\d$/ )        
      }
    ]
  end

  def tag_86( line )
    @tag_86_count = 1
    
    [:tag_86,
     {
       description_1: line.slice( 4, 65 ),
       description_2: ' ',
       description_3: ' ',
       description_4: ' ',
       description_5: ' ',
       description_6: ' '
     }
    ]
  end

  def parse_swift_extra( line )
    if @current_tag == '61'
      # Tag 61 supplementary details
      @swift_array[-1][1][:further_reference] = line.slice( 0, 34 )
    elsif @current_tag == '86'
      # Tag 86 additional lines
      @tag_86_count += 1
      description_sym = 'description_' + @tag_86_count.to_s
      description_sym = description_sym.to_sym
      @swift_array[-1][1][ description_sym ] = line.slice( 0, 34 )
    else
      $stderr.puts "Onbekende tag: #{@current_tag}"
    end
  end

end
