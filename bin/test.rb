require_relative '../lib/swift_classes/swift_file'

teller = 0

File.open('D:\Mijn Documenten\Develop\Swift\Data\DFEZ.SWIFT', 'r') do |f|
  swift = SwiftClasses::SwiftFile.new(f)
  swift.messages.each do |l|
    p l
    teller += 1
    break if teller > 1000
  end
end

