module SwiftClasses

  class SwiftLine
    attr_reader :raw
  
    def initialize( raw_text )
      @fields = {}
      @raw = raw_text.chomp
      convert
    end

    def raw=( raw_text )
      @raw = raw_text.chomp
      convert
    end

    def keys
      @fields.keys
    end

    def field( key )
      # using fetch to force an exeption. Not specifying a valid key
      # indicates not understanding the Swift format
      
      @fields.fetch( key )
    end

    def convert
      # convert MUST be overridden in the subclasses
      
      raise NoMethodError, 'SwiftLine#convert not overridden!' if self.class != SwiftLine
    end

  end
  
end
