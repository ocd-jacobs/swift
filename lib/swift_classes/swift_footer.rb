require_relative 'swift_line'

module SwiftClasses

  class SwiftFooter < SwiftLine
    def convert
      @fields[ :tag ] = 'footer'
      @fields[ :footer ] = raw
    end
  end

end

 
