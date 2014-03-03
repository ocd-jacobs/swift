require 'spec_helper'
require 'swift'
require_relative '../lib/swift_classes/swift_file'

describe SwiftClasses::SwiftFile do
  it 'raises an RuntimeError if not initialized with a File object' do
    expect { SwiftClasses::SwiftFile.new( 'invalid file object' ) }.to raise_error( RuntimeError )
  end

  it 'calculates correct control totals' do
    File.open('D:\Mijn Documenten\Develop\Swift\Data\DFEZ.SWIFT', 'r' ) do | swift_file |
      swift = SwiftClasses::SwiftFile.new( swift_file )
      messages = swift.messages

      expect swift.total_lines.should == 29101
      expect swift.count_addition.should == 4292
      expect swift.amount_addition.should == 10377124021.02
      expect swift.count_subtraction.should == 1358
      expect swift.amount_subtraction.should == -10377124021.02

      expect swift.total_tags[ ':61:' ] == 5650
    end
  end

end

