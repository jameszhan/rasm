module Rasm
  module Java
    class MethodNode
      include Descriptable
      include Accessable

      def initialize(name, descriptor, attributes)
        @name, @descriptor, @attributes = name, descriptor, attributes
      end

      def textify
        to_s
      end

    end
  end
end
