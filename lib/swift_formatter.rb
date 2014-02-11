require_relative 'swift_converter'

class SwiftFormatter
  def initialize( swift_file )
    @swift_array = SwiftConverter.new(swift_file).swift_array
  end

  

  def swift_array
    output_lines = []
    tag61_line = []
    tag_61 = false
    
    @swift_array.each do | line |
      if line [ 0 ] == :tag_61 || line[ 0 ] == :tag_86
        tag_61 = true
      else
        tag_61 = false
        
        unless tag61_line.empty?
          output_lines << process_tag61( tag61_line )
          tag61_line = []
        end
      end

      if tag_61
        tag61_line << line
      else
        output_lines << line
      end
      
    end

    output_lines
  end
  
  def process_tag61( line )
    
  end
end
