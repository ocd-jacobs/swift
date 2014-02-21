require 'spec_helper'
require 'swift'

describe SwiftClasses::SwiftStatementLine do
  context "SEPA compliant" do
    it "converts a properly formatted SEPA compliant statement line" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1310171017C342,40N657561727',
                                                   '/EC-COMPLIANT',
                                                   [
                                                    ':86:/IBAN/NL07ABNA0445655682/BIC/ABNANL2A/NAME/INDONESISCH RESTAURANT',
                                                    ' GAROEDA/RTRN/AC01/REMI/561727 31420/315276 31420/315276 LUNCH/DI',
                                                    'NER 03-10-13/EREF/561727'
                                                   ] )

      line.field( :tag ).should == '61'
      line.field( :value_date ).should == '131017'
      line.field( :entry_date ).should == '1017'
      line.field( :d_c ).should == 'C'
      line.field( :funds_code ).should == ' '
      line.field( :transaction_amount ).should == 342.40
      line.field( :transaction_type ).should == 'N657'
      line.field( :owner_reference ).should == '561727'
      line.field( :servicing_reference ).should == ' '

      line.field( :further_reference ).should == '/EC-COMPLIANT'

      line.field( :iban ).should == 'NL07ABNA0445655682'
      line.field( :bic ).should == 'ABNANL2A'
      line.field( :name ).should == 'INDONESISCH RESTAURANT GAROEDA'
      line.field( :rtrn ).should == 'AC01'
      line.field( :remi ).should == '561727 31420/315276 31420/315276 LUNCH/DINER 03-10-13'
      line.field( :eref ).should == '561727'
      line.field( :purp ).should == ' '
    end
  end

  context "Non SEPA compliant" do
    context "description starts with bank or giro account number" do
      it "converts a line where account number and name are on the same description line - 2 address entries" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1301020102C766,45N196NONREF', 
                                                     '',
                                                     [
                                                      ':86: 11.78.09.357 J.M.J. LEMMERLING',
                                                      'INGBERGRACHTWEG 14 A',
                                                      '6271 CK  GULPEN',
                                                      '20104396/VR*95*/LEMMERLING,JMJ'
                                                     ] )

        line.field( :tag ).should == '61'
        line.field( :value_date ).should == '130102'
        line.field( :entry_date ).should == '0102'
        line.field( :d_c ).should == 'C'
        line.field( :funds_code ).should == ' '
        line.field( :transaction_amount ).should == 766.45
        line.field( :transaction_type ).should == 'N196'
        line.field( :owner_reference ).should == 'NONREF'
        line.field( :servicing_reference ).should == ' '

        line.field( :further_reference ).should == ' '

        line.field( :iban ).should == '11.78.09.357'
        line.field( :bic ).should == ' '
        line.field( :name ).should == 'J.M.J. LEMMERLING'
        line.field( :rtrn ).should == ' '
        line.field( :remi ).should == '20104396/VR*95*/LEMMERLING,JMJ'
        line.field( :eref ).should == ' '
        line.field( :purp ).should == ' '
      end

      it "converts a line where account number and name are on the same description line - 1 address entry" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1303110311C23,50N196NONREF',
                                                     '',
                                                     [
                                                      ':86: 38.29.00.014                    RABO NEDERLAND SPAARBANK',
                                                      'POSTBUS 475                      5600 AL  EINDHOVEN',
                                                      'OVERBOEKING SALDO EN RENTE       OPHEF LLR VALK-OOSTERVELD 29-11-',
                                                      '1333.821.808 E.R. VALK-OOSTERVEL'
                                                     ] )

        line.field( :iban ).should == '38.29.00.014'
        line.field( :rtrn ).should == ' '
        line.field( :name ).should == 'RABO NEDERLAND SPAARBANK'
        line.field( :ordp_id ).should == ' '
        line.field( :remi ).should == 'OVERBOEKING SALDO EN RENTE OPHEF LLR VALK-OOSTERVELD 29-11-1333.821.808 E.R. VALK-OOSTERVEL'
        line.field( :ucrd ).should == ' '
        line.field( :fx ).should == ' '
      end

      it "converts a line where account number and name are not on the same description line" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1301030103C170038,00N196NONREF',
                                                     ' ',
                                                     [
                                                      ':86: 15.75.30.981',
                                                      'LEGER DES HEILS W&G LJ&R',
                                                      'POSTBUS 2055',
                                                      '3500 GB  UTRECHT',
                                                      '88002917/040970'
                                                     ] )

        line.field( :iban ).should == '15.75.30.981'
        line.field( :marf ).should == ' '
        line.field( :name ).should == 'LEGER DES HEILS W&G LJ&R'
        line.field( :svcl ).should == ' '
        line.field( :remi ).should == '88002917/040970'
        line.field( :benm_name ).should == ' '
        line.field( :csid ).should == ' '
      end
      
      it "converts a line starting with 'GIRO' where account number and name are on the same description line - 1 address entry" do
        line = SwiftClasses::SwiftStatementLine.new( ':61:1301020102C6246,44N1960748083495959370',
                                                     '',
                                                     [
                                                      ':86:GIRO   500399                    KPN BV ADM 160 VASTE VER',
                                                      'POSTBUS 13000                    GRONINGEN',
                                                      'BETALINGSKENM.  0748083495959370 200009439120914',
                                                      '200009439120914                  CREDITFACTUUR'
                                                     ] )

        line.field( :iban ).should == '500399'
        line.field( :name ).should == 'KPN BV ADM 160 VASTE VER'
        line.field( :remi ).should == 'BETALINGSKENM. 0748083495959370 200009439120914200009439120914 CREDITFACTUUR'
      end
    end

    it "description starts with an IBAN number (pre februari 2014 SEPA)" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1305270527C115,59N658NONREF',
                                                   '',
                                                   [
                                                    ':86:NL55RBOS0569989760                )(418-RECHTBANK OOST-NEDERLAND ',
                                                    '                                         )(381981 LEVENSLOOPTEGOE',
                                                    'D SAP 20037965 JH VAN BREDA RB OOST NL                           ',
                                                    '                                                     )(381981    ',
                                                    '                         )(                                   )(W'
                                                   ] )

      line.field( :iban ).should == 'NL55RBOS0569989760'
      line.field( :name ).should == '418-RECHTBANK OOST-NEDERLAND'
      line.field( :remi ).should == '381981 LEVENSLOOPTEGOED SAP 20037965 JH VAN BREDA RB OOST NL'
      line.field( :eref ).should == '381981'
      line.field( :ordp_id ).should == ' '
      line.field( :benm_id ).should == 'W' 
    end

    it "converts ZEROBALANCING lines" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1310091009C150611962,99N556ZERO BALANCING S',
                                                   '',
                                                   [
                                                    ':86:ZEROBALANCING',
                                                    'BETWEEN 0569989000 EUR',
                                                    'AND 0569988780 EUR'
                                                   ] )

      line.field( :iban ).should == '0569988780'
      line.field( :name ).should == ' '
      line.field( :remi ).should == 'ZEROBALANCINGBETWEEN 0569989000 EURAND 0569988780 EUR'
    end

    it "converts payment received lines in the new format" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1312231223D1090,21N77801540441995642',
                                                   '',
                                                   [
                                                    ':86:2013122300004653                 BETAALD EUR           1.090,21',
                                                    '/502-282-7                       JAMES BONTA',
                                                    '()441995642 655859 2013 11 26 BO NTAREIS EN VER BLIJFSKOSTEN J BO',
                                                    'NTASYMPOSIUM 26 11 2013          UW REF.   01540441995642'
                                                   ] )

      line.field( :iban ).should == '502-282-7'
      line.field( :name ).should == 'JAMES BONTA'
      line.field( :remi ).should == '2013122300004653 BETAALD EUR 1.090,21()441995642 655859 2013 11 26 BO NTAREIS EN VER BLIJFSKOSTEN J BONTASYMPOSIUM 26 11 2013 UW REF. 01540441995642'
    end

    it "converts payment received lines in the old format" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1301080108D3570,60N785NONREF',
                                                   '',
                                                   [
                                                    ':86:2013010800002904',
                                                    'BETAALD EUR           3.570,60',
                                                    '/AT065700052011022484', 
                                                    'BUNDESMINISTERIUM FUER INNERES',
                                                    'DEB 000017/83436, 83209',
                                                    'MINUS KOSTEN CONFORM AFSPRAAK'
                                                   ] )

      line.field( :iban ).should == 'AT065700052011022484'
      line.field( :name ).should == 'BUNDESMINISTERIUM FUER INNERES'
      line.field( :remi ).should == '2013010800002904BETAALD EUR 3.570,60DEB 000017/83436, 83209MINUS KOSTEN CONFORM AFSPRAAK'
    end

    it "converts properly formatted SEPA compliant payments received" do
      line = SwiftClasses::SwiftStatementLine.new( ':61:1312181218D381,44N307MARF',
                                                   '',
                                                   [
                                                    ':86:COR                                ST2',
                                                    '     /MARF/18002327                     /SVCL/SEPA',
                                                    '          /BENM//NAME/LOYALIS MAATWERK ADMINIS',
                                                    '               /REMI/20131101                     /CSID/NL74LOY14',
                                                    '0657690000          /IBAN/NL61ABNA0421650702           /PURP/OTHR'
                                                   ] )

      line.field( :tag ).should == '61'
      line.field( :value_date ).should == '131218'
      line.field( :entry_date ).should == '1218'
      line.field( :d_c ).should == 'D'
      line.field( :funds_code ).should == ' '
      line.field( :transaction_amount ).should == 381.44
      line.field( :transaction_type ).should == 'N307'
      line.field( :owner_reference ).should == 'MARF'
      line.field( :servicing_reference ).should == ' '

      line.field( :further_reference ).should == ' '

      # ***** REFACTOR *****
      # trailing spaces not consistent
      line.field( :iban ).should == 'NL61ABNA0421650702 '
      line.field( :bic ).should == ' '
      line.field( :name ).should == ' ' 
      line.field( :rtrn ).should == ' '
      line.field( :remi ).should == '20131101 '
      line.field( :eref ).should == ' '
      line.field( :purp ).should == 'OTHR'
      line.field( :svcl ).should == 'SEPA '
      line.field( :marf ).should == '18002327 '
      line.field( :benm_name ).should == 'LOYALIS MAATWERK ADMINIS '
      line.field( :csid ).should == 'NL74LOY140657690000 '
    end

  end
end

