# ******************************************************************************
# File    : SWIFT_LINE.RB
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
# Notes   : Base class for classes representing Swift MT940 lines
# ******************************************************************************

module SwiftClasses

  class SwiftLine
    attr_reader :raw
  
    def initialize( raw_text )
      @fields = {}
      @raw = raw_text.chomp
      convert
    end

    def raw=( raw_text )
      @raw = raw_text.chomp
      convert
    end

    def keys
      @fields.keys
    end

    def field( key )
      # using fetch to force an exeption. Not specifying a valid key
      # indicates not understanding the Swift format
      
      @fields.fetch( key )
    end

    def convert
      # convert MUST be overridden in the subclasses
      
      raise NoMethodError, 'SwiftLine#convert not overridden!' if self.class != SwiftLine
    end

  end
  
end
