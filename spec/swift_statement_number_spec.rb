require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftStatementNumber do
  it "converts a properly formatted statement number line" do
    header = SwiftClasses::SwiftStatementNumber.new( ':28C:36501/1' )
    header.field( :tag ).should == '28'
    header.field( :statement_number ).should == '36501'
    header.field( :sequence_number ).should == '1'
  end
end
