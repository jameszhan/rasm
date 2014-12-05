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

    end
  end
end
