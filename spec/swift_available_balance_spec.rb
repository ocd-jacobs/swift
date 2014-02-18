require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftAvailableBalance do
  it "converts a properly formatted available balance line" do
    header = SwiftClasses::SwiftAvailableBalance.new( ':64:C130809EUR0,95' )
    header.field( :tag ).should == '64'
    header.field( :d_c ).should == 'C'
    header.field( :closing_date ).should == '130809'
    header.field( :currency_code ).should == 'EUR'
    header.field( :available_balance ).should == 0.95
  end
end
