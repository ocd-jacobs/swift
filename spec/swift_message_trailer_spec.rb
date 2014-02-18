require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftMessageTrailer do
  it "converts a properly formatted trailer line" do
    header = SwiftClasses::SwiftMessageTrailer.new( '-}{5:}' )
    header.field( :tag ).should == 'trailer'
    header.field( :trailer ).should == '-}{5:}'
  end
end
