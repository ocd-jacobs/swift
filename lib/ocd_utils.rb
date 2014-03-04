# ******************************************************************************
# File    : OCD_UTILS.RB
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
# Notes   : General utility fuctions
# ******************************************************************************

module OCD_MRJ
  #
  # pretty_print_number
  # Formats a number with thousands separators
  #
  def self::pretty_print_number( number )
    parts = number.to_s.split( '.' )
    parts[ 0 ].gsub!( /(\d)(?=(\d\d\d)+(?!\d))/, "\\1," )
    parts.join( '.' )
  end

  #
  # dutch_number_format
  # Formats a number with periods as thousands separators
  # and a comma as decimal separator
  #
  def self::dutch_number_format( number )
    print_number = pretty_print_number( number )
    
    print_number.gsub!( /\./, '#' )
    print_number.gsub!( /,/, '.' )
    print_number.gsub!( /#/, ',' )

    print_number
  end
end
