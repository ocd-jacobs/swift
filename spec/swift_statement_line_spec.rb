require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftStatementLine do
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
