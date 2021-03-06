# ******************************************************************************
# File    : SWIFT_FILE.RB
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
# Notes   : Class representing a Swift MT940 file
# ******************************************************************************

require_relative '../swift'

module SwiftClasses

  class SwiftFile
    attr_reader :total_lines, :total_tags, :amount_addition, :count_addition, :amount_subtraction, :count_subtraction
    
    def initialize(swift_file_object)
      if swift_file_object.class == File
        @swift_file = swift_file_object
      else
        raise RuntimeError, 'Not a valid File object'
      end

      @messages = []
      @swift_61_string = ''

      @total_lines = 0
      @total_tags = Hash.new(0)

      @amount_addition = 0
      @count_addition = 0
      @amount_subtraction = 0
      @count_subtraction = 0
    end
    
    def messages
      if @messages.empty?
        to_a
      end

      @messages
    end
    
    def to_a
      @swift_file.each do |  line |
        process_swift_line( line )
      end
    end

    def process_swift_line( file_line )
      line = file_line.chomp
      control_count_line( line )
      
      if line =~ /^{\d/
        @message = SwiftMessage.new
        @message.header = SwiftMessageHeader.new( line )
      elsif line =~ /^-}/
        @message.trailer = SwiftMessageTrailer.new( line )
        @messages << @message
      else
        tag = line.slice( /^:[^:]+:/ )

        if tag
          if tag !~ /86/
            @current_tag = tag.gsub( ':', '' ).slice( 0, 2 )
          end
        end
        
        parse_swift_line( line )
      end
    end

    def parse_swift_line( line )
      case @current_tag
      when '20' then @message.transaction_reference = SwiftTransactionReference.new( line )
      when '21' then @message.related_reference = SwiftRelatedReference.new( line )
      when '25' then @message.account_identification = SwiftAccountIdentification.new( line )
      when '28' then @message.statement_number = SwiftStatementNumber.new( line )
      when '60' then @message.opening_balance = SwiftOpeningBalance.new( line )
      when '61' then tag_61( line )
      when '62' then tag_62( line )
      when '64' then @message.available_balance = SwiftAvailableBalance.new( line )
      when '65' then @message.forward_balance = SwiftForwardBalance.new( line )
      else process_unknown( line )
      end
    end

    def tag_61( line )
      tag = line.slice( /:[^:]+:/ )
      
      if tag =~ /61/
        unless @swift_61_string.empty?
          @message.statement_lines << SwiftStatementLine.new( @swift_61_string, @swift_61_extra_string, @swift_86_array )
          control_count_amount( @message.statement_lines[ -1 ] )
        end
        
        @swift_61_string = line
        @swift_61_extra_string = ''
        @swift_86_array = []
      elsif tag =~ /86/
        @swift_61_extra_string = ' ' if @swift_61_extra_string.empty?
        @swift_86_array << line
      else
        if @swift_86_array.empty?
          @swift_61_extra_string = line
        else
          @swift_86_array << line
        end
      end
      
    end

    def tag_62( line )
      tag = line.slice( /:[^:]+:/ )
      
      if tag =~ /62/
        @message.statement_lines << SwiftStatementLine.new( @swift_61_string, @swift_61_extra_string, @swift_86_array )
        control_count_amount( @message.statement_lines[ -1 ] )

        @swift_61_string = ''
        @swift_61_extra_string = ''
        @swift_86_array = []
        @message.closing_balance = SwiftClosingBalance.new( line )
      else
        @swift_86_array << line
      end
    end

    def tag_64( line )
      tag = line.slice( /:[^:]+:/ )
      
      if tag =~ /64/
        @message.available_balance = SwiftAvailableBalance.new( line )
        @swift_86_array = []
      else
        @swift_86_array << line
      end
    end

    def tag_65( line )
      tag = line.slice( /:[^:]+:/ )
      
      if tag =~ /65/
        @message.closing_balance = SwiftClosingBalance.new( line )
        @swift_86_array = []
      else
        @swift_86_array << line
      end
    end

    def process_unknown( line )
      raise RuntimeError, 'Invalid Swift Tag'
    end

    def control_count_line( line )
      @total_lines += 1
      tag = line[ /^:\d\d.?:/ ]
      @total_tags[ tag ] += 1
    end

    def control_count_amount( statement_line)
      amount = statement_line.field( :transaction_amount )
      d_c = statement_line.field( :d_c )

      if d_c == 'C'
        @amount_addition += amount
        @count_addition += 1
      else
        @amount_subtraction -= amount
        @count_subtraction += 1
      end
    end
  end
  
end
