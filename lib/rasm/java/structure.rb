require 'rasm/java/accessable'
module Rasm
  module Java

    class FieldInfo
      include Accessable
      attr_reader :descriptor, :attributes
      def initialize(descriptor, attributes)
        @descriptor, @attributes = descriptor, attributes
      end

      def to_s
        access = access_flags
        str = ''
        str << "\t// DEPRECATED\n" if access & ACC_DEPRECATED != 0
        str << "\t// access flags 0x%x\n" % access
        signature, constant_value = attribute_of('Signature'), attribute_of('ConstantValue')
        if signature
          str << "\t#{access_desc} #{typeof(signature.value)} #{name}"
        else
          str << "\t#{access_desc} #{typeof(descriptor)} #{name}"
        end
        str << " = #{constant_value.value}" if constant_value

        str
      end

      def attribute_of(name)
        attributes.detect{|attr| attr.name == name}
      end

    end

    MethodInfo = Struct.new(:access_flags, :name, :descriptor, :attributes) do

    end
  end
end