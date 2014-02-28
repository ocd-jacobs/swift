require_relative '../lib/swift_classes/swift_file'

message_counter = 0

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

  swift.print_tags
  swift.print_total_amount
end
