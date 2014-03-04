# ******************************************************************************
# File    : SWIFT_CONVERT.RB
# ------------------------------------------------------------------------------
# Author  : J.M. Jacobs
# Date    : 03 March 2014
# Version : 1.0
#
# (C) 2014: Ministerie van Veiligheid en Justitie
#
# Notes   : Converts a Dutch RBS Swift MT940 file to a CSV file
# ******************************************************************************

require_relative '../lib/ocd_utils'
require_relative '../lib/swift_classes/swift_file'

message_counter = 0

def print_tags( swift_file )
  swift_file.total_tags.each do | key, value |
    puts "#{key}\t=>\t#{OCD_MRJ::dutch_number_format( value)}"
  end
end

def print_control_values( swift_file )
  puts " \n\n ----- Controle totalen -----\n\n"
  print_tags( swift_file )
  
  puts "\nTotaal verwerkte regels: " + OCD_MRJ::dutch_number_format( swift_file.total_lines )

  puts "\nAantal bij: " + OCD_MRJ::dutch_number_format( swift_file.count_addition )
  puts "Bedrag bij: " + OCD_MRJ::dutch_number_format( swift_file.amount_addition.to_f )

  puts "\nAantal af: " + OCD_MRJ::dutch_number_format( swift_file.count_subtraction )
  puts "Bedrag af: " + OCD_MRJ::dutch_number_format( swift_file.amount_subtraction.to_f )

  puts "\nTotaal bedrag: " + OCD_MRJ::dutch_number_format( swift_file.amount_addition + swift_file.amount_subtraction )
end

if ARGV[ 0 ].nil? || ARGV[ 0 ].empty?
  $stderr.puts "\n\nUsage: ruby swift_convert.rb <swift_file>\n\n"
  exit
end

unless File.exists?( ARGV[ 0 ] )
  $stderr.puts "\n\nBestand #{ARGV[ 0 ]} niet gevonden!\n\n"
  exit
end

File.open( ARGV[ 0 ], 'r' ) do | file_object |
  output_file = ARGV[ 0 ].downcase.sub( /\.\w+$/, '.csv' )

  if File.exists?( output_file )
    $stderr.puts "\n\n\n*******************************************************************************"
    $stderr.puts '*'
    $stderr.puts "* Uitvoer bestand #{output_file} bastaat al!"
    $stderr.puts '*'
    $stderr.puts "*******************************************************************************\n\n"

    $stderr.print 'Bestand overschrijven (J/N): '
    proceed = $stdin.gets.upcase.chomp
    unless  proceed == 'J'
      $stderr.puts "\n***** Bewerking afgebroken! *****\n"
      file_object.close
      exit
    end
  end
  
  File.open( output_file, 'w' ) do | output |
    swift = SwiftClasses::SwiftFile.new( file_object )
    output.puts "dagafschrift;datum;d_c;bedrag;bedrag_bij;bedrag_af;tegen_rekening;begunstigde;soort_transactie;opmeringen;tag86_text"
    
    swift.messages.each do | message |
      message.statement_lines.each do | statement_line |
        output.print message.statement_number.field( :statement_number ) + '/'
        output.print message.statement_number.field( :sequence_number ) + ';'
        output.print statement_line.field( :value_date ) + ';'
        output.print statement_line.field( :d_c ) + ';'

        amount = statement_line.field( :transaction_amount )
        amount *= -1 if statement_line.field( :d_c ) == 'D'
        amount = amount.to_f.to_s
        
        if statement_line.field( :d_c ) == 'D'
          output.print amount + ';' + '0.0' + ';' + amount + ';'
        else
          output.print amount + ';' + amount + ';' + '0.0' + ';'
        end

        output.print statement_line.field( :iban ) + ';'
        output.print statement_line.field( :name ) + ';'
        output.print statement_line.field( :transaction_type ) + ';'
        output.print statement_line.field( :remi ) + ';'

        output.puts  statement_line.field( :text_86 )
      end

      if $DEBUG
        message_counter += 1
        break if message_counter > 10
      end

    end

    print_control_values( swift )
  end
end
