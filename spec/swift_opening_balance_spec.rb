require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftOpeningBalance do
  it "converts a properly formatted opening balance line" do
    header = SwiftClasses::SwiftOpeningBalance.new( ':60F:C130529EUR34,53' )
    header.field( :tag ).should == '60'
    header.field( :d_c ).should == 'C'
    header.field( :entry_date ).should == '130529'
    header.field( :currency_code ).should == 'EUR'
    header.field( :opening_balance ).should == 34.53
  end
end
