require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftFile do
  it 'raises an RuntimeError if not initialized with a File object' do
    expect { SwiftClasses::SwiftFile.new( 'invalid file object' ) }.to raise_error( RuntimeError )
  end
end
