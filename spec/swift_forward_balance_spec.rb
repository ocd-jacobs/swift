require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftForwardBalance do
  it "converts a properly formatted forward balance line" do
    header = SwiftClasses::SwiftForwardBalance.new( ':65:D131220EUR10,00' )
    header.field( :tag ).should == '65'
    header.field( :d_c ).should == 'D'
    header.field( :forward_date ).should == '131220'
    header.field( :currency_code ).should == 'EUR'
    header.field( :forward_balance ).should == 10.00
  end
end
