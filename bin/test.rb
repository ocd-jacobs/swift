require_relative '../lib/swift_classes/swift_file'

teller = 0

File.open('D:\Mijn Documenten\Develop\Swift\Data\DFEZ.SWIFT', 'r') do |f|
  swift = SwiftClasses::SwiftFile.new(f)
  swift.messages.each do | message |
    message.statement_lines.each do | line |
      print message.statement_number.field( :statement_number ) + '/' + message.statement_number.field( :sequence_number ) + ';'
      print line.field( :value_date ) + ';'
      print line.field( :d_c ) + ';'

      amount = line.field( :transaction_amount )
      if line.field( :d_c ) == 'D'
        amount *= -1
        amount = amount.to_f.to_s
        print amount + ';' + '0.0' + ';' + amount + ';'
      else
        amount = amount.to_f.to_s
        print amount + ';' + amount + ';' + '0.0' + ';'
      end

      print line.field( :iban ) + ';'
      print line.field( :name ) + ';'
      print line.field( :transaction_type ) + ';'
      puts line.field( :remi )

    end
    
    teller += 1
    break if teller > 1000
  end
end

