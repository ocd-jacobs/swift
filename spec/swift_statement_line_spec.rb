require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftStatementLine do
  context "SEPA compliant" do
    it "converts a properly formatted SEPA compliant statement line" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1310171017C342,40N657561727',
                                                   '/EC-COMPLIANT',
                                                   [
                                                    ':86:/IBAN/NL07ABNA0445655682/BIC/ABNANL2A/NAME/INDONESISCH RESTAURANT',
                                                    ' GAROEDA/RTRN/AC01/REMI/561727 31420/315276 31420/315276 LUNCH/DI',
                                                    'NER 03-10-13/EREF/561727'
                                                   ] )
      line.field( :tag ).should == '61'
      line.field( :value_date ).should == '131017'
      line.field( :entry_date ).should == '1017'
      line.field( :d_c ).should == 'C'
      line.field( :funds_code ).should == ' '
      line.field( :transaction_amount ).should == 342.40
      line.field( :transaction_type ).should == 'N657'
      line.field( :owner_reference ).should == '561727'
      line.field( :servicing_reference ).should == ' '

      line.field( :iban ).should == 'NL07ABNA0445655682'
      line.field( :bic ).should == 'ABNANL2A'
      line.field( :name ).should == 'INDONESISCH RESTAURANT GAROEDA'
      line.field( :rtrn ).should == 'AC01'
      line.field( :remi ).should == '561727 31420/315276 31420/315276 LUNCH/DINER 03-10-13'
      line.field( :eref ).should == '561727'
      line.field( :purp ).should == ' '
    end
  end

  context "Non SEPA compliant" do
    context "description starts with a bank account number" do
      it "converts a line where account number and name are on the same description line - 2 address entries" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1301020102C766,45N196NONREF', 
                                                     '',
                                                     [
                                                      ':86: 11.78.09.357 J.M.J. LEMMERLING',
                                                      'INGBERGRACHTWEG 14 A',
                                                      '6271 CK  GULPEN',
                                                      '20104396/VR*95*/LEMMERLING,JMJ'
                                                     ] )
        line.field( :tag ).should == '61'
        line.field( :value_date ).should == '130102'
        line.field( :entry_date ).should == '0102'
        line.field( :d_c ).should == 'C'
        line.field( :funds_code ).should == ' '
        line.field( :transaction_amount ).should == 766.45
        line.field( :transaction_type ).should == 'N196'
        line.field( :owner_reference ).should == 'NONREF'
        line.field( :servicing_reference ).should == ' '
\
        line.field( :iban ).should == '11.78.09.357'
        #line.field( :bic ).should == 'ABNANL2A'
        line.field( :name ).should == 'J.M.J. LEMMERLING'
        #line.field( :rtrn ).should == 'AC01'
        line.field( :remi ).should == '20104396/VR*95*/LEMMERLING,JMJ'
        #line.field( :eref ).should == '561727'
        #line.field( :purp ).should == ' '
      end

      it "converts a line where account number and name are on the same description line - 1 address entry" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1303110311C23,50N196NONREF',
                                                     '',
                                                     [
                                                      ':86: 38.29.00.014                    RABO NEDERLAND SPAARBANK',
                                                      'POSTBUS 475                      5600 AL  EINDHOVEN',
                                                      'OVERBOEKING SALDO EN RENTE       OPHEF LLR VALK-OOSTERVELD 29-11-',
                                                      '1333.821.808 E.R. VALK-OOSTERVEL'
                                                     ] )
        line.field( :tag ).should == '61'
        line.field( :value_date ).should == '130311'
        line.field( :entry_date ).should == '0311'
        line.field( :d_c ).should == 'C'
        line.field( :funds_code ).should == ' '
        line.field( :transaction_amount ).should == 23.50
        line.field( :transaction_type ).should == 'N196'
        line.field( :owner_reference ).should == 'NONREF'
        line.field( :servicing_reference ).should == ' '
\
        line.field( :iban ).should == '38.29.00.014'
        #line.field( :bic ).should == ' '
        line.field( :name ).should == 'RABO NEDERLAND SPAARBANK'
        #line.field( :rtrn ).should == 'AC01'
        line.field( :remi ).should == 'OVERBOEKING SALDO EN RENTE OPHEF LLR VALK-OOSTERVELD 29-11-1333.821.808 E.R. VALK-OOSTERVEL'
        #line.field( :eref ).should == '561727'
        #line.field( :purp ).should == ' '
      end

      it "converts a line where account number and name are not on the same description line" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1301030103C170038,00N196NONREF',
                                                     ' ',
                                                     [
                                                      ':86: 15.75.30.981',
                                                      'LEGER DES HEILS W&G LJ&R',
                                                      'POSTBUS 2055',
                                                      '3500 GB  UTRECHT',
                                                      '88002917/040970'
                                                     ] )
        line.field( :tag ).should == '61'
        line.field( :value_date ).should == '130103'
        line.field( :entry_date ).should == '0103'
        line.field( :d_c ).should == 'C'
        line.field( :funds_code ).should == ' '
        line.field( :transaction_amount ).should == 170038.00
        line.field( :transaction_type ).should == 'N196'
        line.field( :owner_reference ).should == 'NONREF'
        line.field( :servicing_reference ).should == ' '

        line.field( :iban ).should == '15.75.30.981'
        #line.field( :bic ).should == 'ABNANL2A'
        line.field( :name ).should == 'LEGER DES HEILS W&G LJ&R'
        #line.field( :rtrn ).should == 'AC01'
        line.field( :remi ).should == '88002917/040970'
        #line.field( :eref ).should == '561727'
        #line.field( :purp ).should == ' '
      end
      
    end
  end
end

