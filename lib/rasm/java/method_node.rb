module Rasm
  module Java
    class MethodNode
      include Descriptable
      include Accessable

      attr_accessor :signature, :annotation_default, :code

      def initialize(name, descriptor, attributes)
        @name, @descriptor, @attributes = name, descriptor, attributes
      end

      def exceptions
        @exceptions ||= []
      end

      def visible_annotations
        @visible_annotations ||= []
      end

      def invisible_annotations
        @invisible_annotations ||= []
      end

      def visible_param_annotations
        @visible_parameter_annotations ||= []
      end

      def invisible_param_annotations
        @invisible_param_annotations ||= []
      end

      def instructions
        @instructions ||= []
      end

      def try_catch_blocks
        @try_catch_blocks ||= []
      end

      def local_variables
        @local_variables ||= []
      end

      def sync
        attributes.each do|attribute|
          case attribute.name
            when 'Signature'
              self.signature = attribute.value
            when 'Deprecated'
              self.access_flags |= ACC_DEPRECATED
            when 'Synthetic'
              self.access_flags |= ACC_SYNTHETIC | ACC_SYNTHETIC_ATTRIBUTE
            when 'AnnotationDefault'
            when 'Code'
              self.code = attribute.value
            when 'Exceptions'
              @exceptions = attribute.value
            when 'RuntimeVisibleAnnotations'
              visible_annotations.concat(attribute.value)
            when 'RuntimeInvisibleAnnotations'
              invisible_annotations.concat(attribute.value)
            when 'RuntimeVisibleParameterAnnotations'
              visible_param_annotations.concat(attribute.value)
            when 'RuntimeInvisibleParameterAnnotations'
              invisible_param_annotations.concat(attribute.value)
            else
              puts '->', attribute.name, attribute.data.length
          end
        end
      end

      def accept(&block)

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

        str << "\t"
        str << access_desc
        if access & ACC_NATIVE != 0
            str << 'native '
        end
        if access & ACC_VARARGS != 0
          str << 'varargs '
        end
        if access & ACC_BRIDGE != 0
          str << 'bridge '
        end

        str << "#{name}#{descriptor}"
        str << " throws #{exceptions.join(', ')}" unless exceptions.empty?
        str << "\n"

        visible_annotations.each do|ann|
          str << "\t\t#{ann.textify}\n"
        end
        invisible_annotations.each do|ann|
          str << "\t\t#{ann.textify} // invisible\n"
        end
        visible_param_annotations.each do|ann|
          str << "\t\t#{ann.textify} // parameter #{ann.options[:param_seq]}\n"
        end
        invisible_param_annotations.each do|ann|
          str << "\t\t#{ann.textify} // invisible parameter\n"
        end
        str
      end

    end
  end
end
