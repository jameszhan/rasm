module Rasm
  module Java
    module ACC
      def acc

      end
    end

    ClassInfo = Struct.new(:access_flags, :this_class, :super_class, :interfaces) do
      include ACC
    end

    FieldInfo = Struct.new(:access_flags, :name, :descriptor, :attributes) do
      include ACC
    end

    MethodInfo = Struct.new(:access_flags, :name, :descriptor, :attributes) do
      include ACC
    end
  end
end