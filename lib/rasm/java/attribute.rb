module Rasm
  module Java
    class Attribute
      attr_reader :name, :data
      def initialize(cp, name, data)
        @cp, @name, @data = cp, name, data
      end

      def value
        @cp[@data.unpack('n')[0]].val
      end

      class << self
        def of(cp, name, data)
          type = begin
            "Rasm::Java::#{name}Attribute".constantize
          rescue
            Attribute
          end
          type.new(cp, name, data)
        end
      end
    end

    class DeprecatedAttribute < Attribute
      def value
        true
      end
    end
  end
end
