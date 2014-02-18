require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftMessageHeader do
  it "converts a properly formatted header line" do
    header = SwiftClasses::SwiftMessageHeader.new( '{1:F01RBOSNL2AXXXX0000000000}{2:O9400000000000RBOSNL2AXXXX00000000000000000000N}{3:}{4:' )
    header.field( :tag ).should == 'header'
    header.field( :header ).should == '{1:F01RBOSNL2AXXXX0000000000}{2:O9400000000000RBOSNL2AXXXX00000000000000000000N}{3:}{4:'
  end
end
