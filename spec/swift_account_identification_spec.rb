require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftAccountIdentification do
  it "converts a properly formatted account identification line" do
    header = SwiftClasses::SwiftAccountIdentification.new( ':25:569989000RBOSNL2AEUR569989000EUR' )
    header.field( :tag ).should == '25'
    header.field( :account_identification ).should == '569989000RBOSNL2AEUR569989000EUR'
  end
end
