module Rasm
  module Java
    class Attribute
      attr_reader :name
      def initialize(cp, name, data)
        @cp, @name, @data = cp, name, data
      end

      def value
        @cp[@data.unpack('n')[0]].val
      end

      class << self
        def of(cp, name, data)
          case name
            when 'Code'

            else
              Attribute.new(cp, name, data)
          end
        end
      end
    end
  end
end
