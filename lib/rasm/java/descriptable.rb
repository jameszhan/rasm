module Rasm
  module Java
    module Descriptable

      attr_accessor :name, :descriptor, :attributes

      CONSTANTS_MAP = {
        Z: 'boolean',
        B: 'byte'   ,
        C: 'char'   ,
        S: 'short'  ,
        I: 'int'    ,
        F: 'float'  ,
        J: 'long'   ,
        D: 'double' ,
        V: 'void'   ,
        '-'.to_sym => '? super ',
        '+'.to_sym => '? extends '
      }

      def attributes
        @attributes ||= []
      end

      def attribute_of(name)
        attributes.detect{|attr| attr.name == name}
      end

      def typeof(descriptor)
        parse_type(StringScanner.new(descriptor), 0)
      end

      private
        def parse_type(scanner, level)
          str, flag = '', scanner.peek(1)
          case flag
            when 'Z','B','C','S','I','F','J','D','V'
              str << CONSTANTS_MAP[flag.to_sym]
            when '['
              scanner.scan(/\[/)
              str << '%s[]' % parse_type(scanner, level + 1)
            when 'T'
              start = scanner.pos
              scanner.scan_until(/;/)
              str << scanner.string[start...scanner.pos - 2]
            else # when 'L'
              visited = false
              scanner.scan(/L/)
              start = scanner.pos
              begin
                ch = scanner.getch
                case ch
                  when ';'
                    str << scanner.string[start...scanner.pos - 1] unless visited
                    break
                  when '<'
                    str << scanner.string[start...scanner.pos - 1]
                    visited = true
                    str << ch
                    ret = []
                    begin
                      char = scanner.getch
                      case char
                        when '>'
                          str << ret.join(', ')
                          str << char
                          break
                        when '+', '-'
                          ret << CONSTANTS_MAP[char.to_sym] + parse_type(scanner, level + 1)
                        when '*'
                          ret << '?'
                        else
                          scanner.unscan
                          ret << parse_type(scanner, level + 1)
                      end
                    end until scanner.eos?
                  else
                    scanner.skip(/[^;<>\+\-\*]+/)
                end
              end until scanner.eos?
          end
          str
        end
    end
  end
end
