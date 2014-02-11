require_relative '../lib/swift_converter'

teller = 0

File.open('D:\Mijn Documenten\Develop\Swift-Refactor\Data\DFEZ.SWIFT', 'r') do |f|
  swift = SwiftConverter.new(f)
  swift.swift_array.each do |l|
    p l
    teller += 1
    break if teller > 1000
  end
end

