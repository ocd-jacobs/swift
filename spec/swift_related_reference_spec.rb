require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftRelatedReference do
  it "converts a properly formatted related reference line" do
    header = SwiftClasses::SwiftRelatedReference.new( ':21:NON-RELATED' )
    header.field( :tag ).should == '21'
    header.field( :related_reference ).should == 'NON-RELATED'
  end
end
