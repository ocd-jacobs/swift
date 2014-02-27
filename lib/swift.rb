require_relative 'swift_classes/swift_line'                        # swift line base class
require_relative 'swift_classes/swift_message_header'              # message header
require_relative 'swift_classes/swift_transaction_reference'       # tag :20:
require_relative 'swift_classes/swift_related_reference'           # tag :21:
require_relative 'swift_classes/swift_account_identification'      # tag :25:
require_relative 'swift_classes/swift_statement_number'            # tag :28x:
require_relative 'swift_classes/swift_opening_balance'             # tag :60x:
require_relative 'swift_classes/swift_statement_line'              # tag :61:
require_relative 'swift_classes/swift_closing_balance'             # tag :62x:
require_relative 'swift_classes/swift_available_balance'           # tag :64:
require_relative 'swift_classes/swift_forward_balance'             # tag :65:
require_relative 'swift_classes/swift_message_description'         # tag :86:
require_relative 'swift_classes/swift_message_trailer'             # message trailer

require_relative 'swift_classes/swift_message'                     # swift message
#require_relative 'swift_classes/swift_file'                        # swift file
