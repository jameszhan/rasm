require 'rasm/java/constant_type'
require 'rasm/java/accessable'
require 'rasm/java/descriptable'
require 'rasm/java/attribute'
require 'rasm/java/class_node'
require 'rasm/java/field_node'
require 'rasm/java/method_node'
require 'rasm/java/annotation_node'

module Rasm
  module Java
    #
    # ClassFile {
    #     u4 magic;
    #     u2 minor_version;
    #     u2 major_version;
    #     u2 constant_pool_count;
    #     cp_info constant_pool[constant_pool_count-1];
    #     u2 access_flags;
    #     u2 this_class;
    #     u2 super_class;
    #     u2 interfaces_count;
    #     u2 interfaces[interfaces_count];
    #     u2 fields_count;
    #     field_info fields[fields_count];
    #     u2 methods_count;
    #     method_info methods[methods_count];
    #     u2 attributes_count;
    #     attribute_info attributes[attributes_count];
    # }
    #
    class Bytecode

      class << self
        def of(class_file, options = {})
          self.new.read(class_file, options)
        end
      end

      def read(class_file, options={})
        class_node = ClassNode.new
        open class_file, 'rb' do|io|
          magic = io.read(4).unpack('N')[0]
          if magic == 0xCAFEBABE
            class_node.version = io.read(4).unpack('nn').reverse.join('.')
            pull_cp_info(io, options[:verbose])

            access_flags, this_class, super_class, interfaces_count = io.read(8).unpack('n*')
            interfaces = interfaces_count > 0 ? io.read(2 * interfaces_count).unpack('n*').map{|item| constant_pool[item].val} : []
            class_node.access_flags, class_node.name, class_node.super_name, class_node.interfaces = access_flags, constant_pool[this_class].val, constant_pool[super_class].val, interfaces

            class_node.field_nodes.concat pull_list(io, FieldNode)
            class_node.method_nodes.concat pull_list(io, MethodNode)
            class_node.attributes = pull_attributes(io)
          else
            raise "magic #{magic} is not valid java class file."
          end
        end
        class_node
      end

      def constant_pool
        @constant_pool ||= {}
      end

      private
        def pull_cp_info(io, verbose)
          @constant_pool_count = io.read(2).unpack('n')[0]
          i = 1
          while i < @constant_pool_count
            tag = io.read(1).unpack('C')[0]
            constant_type = CONSTANT_TYPES[tag]
            if constant_type
              target = constant_type.value_at(io)
              constant_pool[i] = target.respond_to?(:call) ? target.call(constant_pool) : target
            end
            i += 1 if tag == 5 || tag == 6
            i += 1
          end
          if verbose
            str = "constant_pool (#{@constant_pool_count}) \n"
            constant_pool.each do|j, e|
              if e.is_a? Ref
                str << "#%02d = %-16s %-20s %s\n" % [j, e.name, e, ("//#{e.val}" if e.is_a?(Ref))]
              else
                str << "#%02d = %-16s %-20s\n" % [j, e.name, e.val]
              end
            end
            puts str
          end
        end

        def pull_list(io, type)
          fields_count = io.read(2).unpack('n')[0]
          items = []
          if fields_count > 0
            fields_count.times do
              access_flags, name_index, descriptor_index = io.read(6).unpack('n*')
              attributes = pull_attributes(io)
              item = type.new(constant_pool[name_index].val, constant_pool[descriptor_index].val, attributes)
              item.access_flags = access_flags
              items << item
            end
          end
          items
        end

        def pull_attributes(io)
          attributes_count = io.read(2).unpack('n')[0]
          attributes = []
          attributes_count.times do
            attribute_name_index, attribute_length = io.read(6).unpack('nN')
            name = constant_pool[attribute_name_index].val
            attributes << Attribute.of(constant_pool, name, io.read(attribute_length))
          end
          attributes
        end
    end

  end
end