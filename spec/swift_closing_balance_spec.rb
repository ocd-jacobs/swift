require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftClosingBalance do
  it "converts a properly formatted closing balance line" do
    header = SwiftClasses::SwiftClosingBalance.new( ':62F:C130813EUR23,56' )
    header.field( :tag ).should == '62'
    header.field( :d_c ).should == 'C'
    header.field( :closing_date ).should == '130813'
    header.field( :currency_code ).should == 'EUR'
    header.field( :closing_balance ).should == 23.56
  end
end
