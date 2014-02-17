require_relative 'swift_line'

module SwiftClasses
  
  class SwiftMessageDescription < SwiftLine
    def initialize(swift_86_array)
      descriptions = ''
      swift_86_array.each do |description|
        descriptions += description
      end

      super( descriptions )
    end

    def convert
      @fields[ :tag ] = 'description'
      @fields[ :message_description ] = @raw.sub( /^:[^:]+:/, '')
    end
  end
  
end
