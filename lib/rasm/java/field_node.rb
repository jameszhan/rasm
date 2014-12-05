module Rasm
  module Java
    class FieldNode
      include Descriptable
      include Accessable

      def initialize(name, descriptor, attributes)
        @name, @descriptor, @attributes = name, descriptor, attributes
      end

      def textify
        access = access_flags
        str = ''
        str << "\t// DEPRECATED\n" if access & ACC_DEPRECATED != 0
        str << "\t// access flags 0x%x\n" % access
        signature, constant_value = attribute_of('Signature'), attribute_of('ConstantValue')
        if signature
          str << "\t// signature #{signature.value}\n"
          str << "\t// declaration #{typeof(signature.value).gsub('/', '.')}\n"
        else
          str << "\t// declaration #{typeof(descriptor)}\n"
        end
        str << "\t#{access_desc} #{descriptor} #{name}"
        str << " = #{constant_value.value}" if constant_value
        str << "\n"
        str
      end

    end
  end
end
