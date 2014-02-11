require 'swift_converter'

describe SwiftConverter do
  it 'raises an RuntimeError if not initialized with a File object' do
    expect { SwiftConverter.new( 'invalid file object' ) }.to raise_error( RuntimeError )
  end

  it 'returns a non empty array when given a valid SWIFT file' do
    swift_file = SwiftConverter.new( File.new( 'D:\Mijn Documenten\Develop\Swift-Refactor\Data\DFEZ.SWIFT', 'r') )
    swift_array = swift_file.swift_array
    expect( swift_array.empty? ).to be_false
  end
end
