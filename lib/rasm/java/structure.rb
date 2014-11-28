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
        str << "\t#{access_desc} #{typeof(descriptor)} #{name}"
        str << " = #{attributes}" unless attributes.empty?
        str
      end

    end

    MethodInfo = Struct.new(:access_flags, :name, :descriptor, :attributes) do

    end
  end
end