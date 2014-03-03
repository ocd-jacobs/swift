# ******************************************************************************
# File: OCD-UTILS
# ------------------------------------------------------------------------------
# General utility fuctions
# ******************************************************************************

#
# pretty_print_number
# Formats a number with thousands separators
#
def pretty_print_number( number )
  parts = number.to_s.split( '.' )
  parts[ 0 ].gsub!( /(\d)(?=(\d\d\d)+(?!\d))/, "\\1," )
  parts.join( '.' )
end

#
# dutch_number_format
# Formats a number with periods as thousands separators
# and a comma as decimal separator
#
def dutch_number_format( number )
  print_number = pretty_print_number( number )
  
  print_number.gsub!( /\./, '#' )
  print_number.gsub!( /,/, '.' )
  print_number.gsub!( /#/, ',' )

  print_number
end
