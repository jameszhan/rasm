module Rasm
  module Java
    class ClassNode
      include Accessable
      include Descriptable

      attr_accessor :version, :signature, :super_name, :source_file, :source_debug, :outer_class, :outer_method,

      def interfaces
        @interfaces ||= []
      end

      def visible_annotations
        @visible_annotations ||= []
      end

      def invisible_annotations
        @invisible_annotations ||= []
      end

      def field_nodes
        @field_nodes ||= []
      end

      def method_nodes
        @method_nodes ||= []
      end

      def inner_classes
        @inner_classes ||= []
      end

      def sync
        attributes.each do|attribute|
          case attribute.name
            when 'SourceFile'
              self.source_file = attribute.value
            when 'SourceDebugExtension'
              self.source_debug = attribute.value
            when 'InnerClasses'
              inner_classes.concat(attribute.value)
            when 'Deprecated'
              self.access_flags |= ACC_DEPRECATED
            when 'Synthetic'
              self.access_flags |= ACC_SYNTHETIC | ACC_SYNTHETIC_ATTRIBUTE
            when 'Signature'
              self.signature = attribute.value
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
        str = "// version #{version}\n"

        access = access_flags
        if access & ACC_DEPRECATED != 0
          str << "// DEPRECATED\n"
        end
        str << "// access flags 0x%x\n" % access

        str << "// signature: #{signature}\n" if signature
        str << access_desc
        if (access & ACC_ANNOTATION) != 0
          str << '@interface '
        elsif (access & ACC_INTERFACE) != 0
          str << 'interface ';
        elsif (access & ACC_ENUM) == 0
          str << 'class '
        end
        str << name
        str << " extends #{super_name} " if super_name && super_name != 'java/lang/Object'
        str << ' implements %s {' % interfaces.join(',') unless interfaces.empty?

        str << "\n\t// compiled from: #{source_file}\n" if source_file
        str << "\n\t// debug info: #{source_debug}\n" if source_debug

        visible_annotations.each do|ann|
          str << "\n\t#{ann.textify}\n"
        end

        invisible_annotations.each do|ann|
          str << "\n\t#{ann.textify} // invisible\n"
        end

        field_nodes.each do|f|
          str << "#{f.textify}\n"
        end
        method_nodes.each do|m|
          str << "#{m.textify}\n"
        end

        str << "// inner_classes [#{inner_classes.join(',')}]"
        str << "\n}"
        str
      end

    end
  end
end
