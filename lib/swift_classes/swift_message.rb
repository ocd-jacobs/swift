module SwiftClasses

  class SwiftMessage
    attr_accessor :header, :transaction_reference, :related_reference, :account_identification,
                  :statement_number, :opening_balance, :statement_lines, :closing_balance,
                  :available_balance, :forward_balance, :description, :trailer
  
    def initialize
      @statement_lines = []
    end
  end
  
end
