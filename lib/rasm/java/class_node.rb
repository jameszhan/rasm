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
        source_file, deprecated, anns, ianns = attribute_of('SourceFile'), attribute_of('Deprecated'), attribute_of('RuntimeVisibleAnnotations'), attribute_of('RuntimeInvisibleAnnotations')
        self.source_file = source_file.value if source_file
        self.access_flags |= ACC_DEPRECATED if deprecated

        puts "===================="
        p anns.value
        puts "*******************"
        p ianns.value
        puts "===================="
      end

      def textify
        self.sync
        str = "// version #{version}\n"
        signature = attribute_of('Signature')

        access = access_flags
        if access & ACC_DEPRECATED != 0
          str << "// DEPRECATED\n"
        end
        str << "// access flags 0x%x\n" % access

        str << "// signature: #{signature.value}\n" if signature
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
        str << " implements %s {" % interfaces.join(',') unless interfaces.empty?

        str << "\n\t// compiled from: #{source_file}\n\n" if source_file

        field_nodes.each do|f|
          str << "#{f.textify}\n"
        end
        method_nodes.each do|m|
          str << "#{m.textify}\n"
        end
        str << "\n}"
        str
      end

    end
  end
end
