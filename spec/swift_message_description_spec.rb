require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftMessageDescription do
  it "converts a properly formatted description line" do
    description = SwiftClasses::SwiftMessageDescription.new( [':86: 60.34.19.658',
                                                              'LOYALIS LEVEN NV@INZAKE',
                                                              'POSTBUS 4916',
                                                              '6401 JS  HEERLEN',
                                                              '27815353 LL MMF VAN ZANDVOORT'
                                                             ] )
    description.field( :tag ).should == 'description'
    description.field( :message_description ).should == ' 60.34.19.658 LOYALIS LEVEN NV@INZAKE POSTBUS 4916 6401 JS  HEERLEN 27815353 LL MMF VAN ZANDVOORT '
  end
end
