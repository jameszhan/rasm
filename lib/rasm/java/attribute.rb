module Rasm
  module Java
    class Attribute
      attr_reader :name, :data

      def initialize(cp, name, data)
        @cp, @name, @data = cp, name, data
      end

      def value
        @cp[@data.unpack('n')[0]].val
      end

      class << self
        def of(cp, name, data)
          type = case name
            when 'Deprecated', 'Synthetic'
              FlagAttribute
            when 'RuntimeVisibleAnnotations', 'RuntimeInvisibleAnnotations'
              AnnotationsAttribute
            when 'RuntimeVisibleParameterAnnotations', 'RuntimeInvisibleAnnotations'
              ParamAnnotationsAttribute
            when 'AnnotationDefault'
              AnnotationAttribute
            when 'InnerClasses'
              InnerClassesAttribute
            when 'Exceptions'
              ExceptionsAttribute
            when 'Code'
              CodeAttribute
            else
              Attribute
          end
          type.new(cp, name, data)
        end
      end
    end

    class FlagAttribute < Attribute
      def value
        true
      end
    end

    class SourceDebugExtensionAttribute < Attribute
      def value
        data.unpack('a*')
      end
    end

    class ExceptionsAttribute < Attribute
      def value
        io = StringIO.new(data)
        count = io.read(2).unpack('n')[0]
        io.read(2 * count).unpack('n' * count).map{|index| @cp[index].val}
      end
    end

    class CodeAttribute < Attribute
      def value
        StringIO.open(data)do|io|
          max_stack, max_stack, code_length = io.read(8).unpack('nnN')
          puts max_stack, max_stack, code_length
          puts "--------------"
        end
      end
    end

    class InnerClassesAttribute < Attribute
      def value
        classes = []
        StringIO.open(data) do|io|
          count = io.read(2).unpack('n')[0]
          count.times do
            inner_class_info_index, outer_class_info_index, inner_name_index, inner_class_access_flags = io.read(8).unpack('nnnn')
            classes << @cp[inner_class_info_index].val
          end
        end if data && data.length > 0
        classes
      end
    end

    class AnnotationAttribute < Attribute
      def value
        element_value(StringIO.new(data))
      end

      def element_values(io, named)
        values = []
        count = io.read(2).unpack('n')[0]
        count.times do
          if named
            name_index = io.read(2).unpack('n')[0]
            val = element_value(io)
            values << [@cp[name_index].val, val]
          else
            values << element_value(io)
          end
        end
        values
      end

      def element_value(io)
        tag = io.read(1).unpack('A')[0]
        case tag
          when 'B', 'Z', 'S', 'C', 'I', 'J', 'F', 'D', 's', 'c'
            [tag, @cp[io.read(2).unpack('n')[0]].val]
          when 'e'
            type_name_index, const_name_index = io.read(4).unpack('nn')
            [tag, [@cp[type_name_index].val, @cp[const_name_index].val]]
          when '@'
            [tag, element_values(io, true)]
          when '['
            array_length = io.read(2).unpack('n')[0]
            if array_length > 0
              array = []
              array_length.times do
                type = io.read(1).unpack('A')[0]
                case type
                  when 'B', 'Z', 'S', 'C', 'I', 'J', 'F', 'D', 's', 'c'
                    array << [type, @cp[io.read(2).unpack('n')[0]].val]
                  else
                    array << [type, element_values(io, false)]
                end
              end
              array
            else
              []
            end
          else
            element_values(io, false)
        end
      end
    end

    class AnnotationsAttribute < AnnotationAttribute

      def value
        anns = []
        StringIO.open(data) do |io|
          ann_count = io.read(2).unpack('n')[0]
          ann_count.times do
            type_index = io.read(2).unpack('n')[0]
            anns << AnnotationNode.new(@cp[type_index].val, element_values(io, true))
          end
        end if data && data.length > 0
        anns
      end

    end


    class ParamAnnotationsAttribute < AnnotationAttribute
      def value
        anns = []
        StringIO.open(data) do |io|
          param_count = io.read(1).unpack('C')[0]
          param_count.times do|i|
            ann_count = io.read(2).unpack('n')[0]
            ann_count.times do
              type_index = io.read(2).unpack('n')[0]
              anns << AnnotationNode.new(@cp[type_index].val, element_values(io, true), param_seq: i)
            end
          end
        end if data && data.length > 0
        anns
      end
    end


  end
end
