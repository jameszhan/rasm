module Rasm
  module Java
    class FieldNode
      include Descriptable
      include Accessable

      attr_accessor :signature, :constant_value

      def initialize(name, descriptor, attributes)
        @name, @descriptor, @attributes = name, descriptor, attributes
      end

      def visible_annotations
        @visible_annotations ||= []
      end

      def invisible_annotations
        @invisible_annotations ||= []
      end

      def sync
        attributes.each do|attribute|
          case attribute.name
            when 'ConstantValue'
              self.constant_value = attribute.value
            when 'Signature'
              self.signature = attribute.value
            when 'Deprecated'
              self.access_flags |= ACC_DEPRECATED
            when 'Synthetic'
              self.access_flags |= ACC_SYNTHETIC | ACC_SYNTHETIC_ATTRIBUTE
            when 'RuntimeVisibleAnnotations'
              visible_annotations.concat(attribute.value)
            when 'RuntimeInvisibleAnnotations'
              invisible_annotations.concat(attribute.value)
            else
              puts '->', attribute.name, attribute.data.length
          end
        end
      end

      def textify
        self.sync
        access = access_flags
        str = ''
        str << "\t// DEPRECATED\n" if access & ACC_DEPRECATED != 0
        str << "\t// access flags 0x%x\n" % access
        if signature
          str << "\t// signature #{signature}\n"
          str << "\t// declaration #{typeof(signature).gsub('/', '.')}\n"
        else
          str << "\t// declaration #{typeof(descriptor)}\n"
        end
        str << "\t#{access_desc} #{descriptor} #{name}"
        str << " = #{constant_value}" if constant_value
        str << "\n"
        visible_annotations.each do|ann|
          str << "\t#{ann.textify}\n"
        end
        invisible_annotations.each do|ann|
          str << "\t#{ann.textify} // invisible\n"
        end
        str
      end

    end
  end
end
