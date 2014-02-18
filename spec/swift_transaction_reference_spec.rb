require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftTransactionReference do
  it "converts a properly formatted transaction reference line" do
    header = SwiftClasses::SwiftTransactionReference.new( ':20:NONREF' )
    header.field( :tag ).should == '20'
    header.field( :transaction_reference ).should == 'NONREF'
  end
end
