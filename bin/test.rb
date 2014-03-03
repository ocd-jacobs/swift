require_relative '../lib/ocd-utils'
require_relative '../lib/swift_classes/swift_file'

message_counter = 0

def print_tags( swift_file )
  swift_file.total_tags.each do | key, value |
    $stderr.puts "#{key}\t=>\t#{dutch_number_format( value)}"
  end
end

def print_control_values( swift_file )
  $stderr.puts " \n\n ----- Controle totalen -----\n\n"
  print_tags( swift_file )
  
  $stderr.puts "\nTotaal verwerkte regels: " + dutch_number_format( swift_file.total_lines )

  $stderr.puts "\nAantal bij: " + dutch_number_format( swift_file.count_addition )
  $stderr.puts "Bedrag bij: " + dutch_number_format( swift_file.amount_addition.to_f )

  $stderr.puts "\nAantal af: " + dutch_number_format( swift_file.count_subtraction )
  $stderr.puts "Bedrag af: " + dutch_number_format( swift_file.amount_subtraction.to_f )

  $stderr.puts "\nTotaal bedrag: " + dutch_number_format( swift_file.amount_addition + swift_file.amount_subtraction )
end

File.open( ARGV[ 0 ], 'r' ) do | file_object |
  swift = SwiftClasses::SwiftFile.new( file_object )
  swift.messages.each do | message |
    message.statement_lines.each do | statement_line |
      print message.statement_number.field( :statement_number ) + '/'
      print message.statement_number.field( :sequence_number ) + ';'
      print statement_line.field( :value_date ) + ';'
      print statement_line.field( :d_c ) + ';'

      amount = statement_line.field( :transaction_amount )
      amount *= -1 if statement_line.field( :d_c ) == 'D'
      amount = amount.to_f.to_s
      
      if statement_line.field( :d_c ) == 'D'
        print amount + ';' + '0.0' + ';' + amount + ';'
      else
        print amount + ';' + amount + ';' + '0.0' + ';'
      end

      print statement_line.field( :iban ) + ';'
      print statement_line.field( :name ) + ';'
      print statement_line.field( :transaction_type ) + ';'
      print statement_line.field( :remi ) + ';'

      puts  statement_line.field( :text_86 )
    end

    if $DEBUG
      message_counter += 1
      break if message_counter > 10
    end

  end

  print_control_values( swift )
end
