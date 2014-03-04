# ******************************************************************************
# File    : SWIFT_STATEMENT_NUMBER.RB
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
# Notes   : Class representing a Swift MT940 statement number (tag :28x:)
# ******************************************************************************

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

