require 'rasm/java/constant_type'
require 'rasm/java/structure'
require 'rasm/java/accessable'

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
      include Accessable

      attr_reader :version, :super_class, :interfaces, :fields, :methods, :attributes

      def initialize(class_file)
        open class_file, 'rb' do|io|
          magic = io.read(4).unpack('N')[0]
          if magic == 0xCAFEBABE
            @version = io.read(4).unpack('nn').reverse.join('.')
            pull_cp_info(io)

            self.access_flags, this_class, super_class, interfaces_count = io.read(8).unpack('n*')
            @interfaces = interfaces_count > 0 ? io.read(2 * interfaces_count).unpack('n*').map{|item| constant_pool[item].val} : []
            self.name, @super_class = constant_pool[this_class].val, constant_pool[super_class].val

            @fields = pull_list(io, FieldInfo)
            @methods = pull_list(io, MethodInfo)
            @attributes = pull_attributes(io)
          else
            raise "magic #{magic} is not valid java class file."
          end
        end
      end

      def to_s
        access = access_flags
        str = ''
        if access & ACC_DEPRECATED != 0
          str << "//DEPRECATED\n"
        end
        str << "// access flags 0x%x\n" % access
        str << access_desc
        if (access & ACC_ANNOTATION) != 0
          str << '@interface '
        elsif (access & ACC_INTERFACE) != 0
          str << 'interface ';
        elsif (access & ACC_ENUM) == 0
          str << 'class '
        end
        str << name
        str << " extends #{super_class} " if super_class && super_class != 'java/lang/Object'
        str << " implements %s {\n" % interfaces.join(',') unless interfaces.empty?
        fields.each do|f|
          str << "#{f}\n"
        end
        str << "\n}"
        str
      end


      def constant_pool
        @constant_pool ||= {}
      end

      def cp_info
        str = "cp_info (#{@constant_pool_count}) \n"
        constant_pool.each do|i, e|
          str << "#%02d = %-16s %-20s %s\n" % [i, e.name, e, ("//#{e.val}" if e.is_a?(Ref))]
        end
        str
      end

      private
        def pull_cp_info(io)
          @constant_pool_count = io.read(2).unpack('n')[0]
          no = 1
          while no < @constant_pool_count
            tag = io.read(1).unpack('C')[0]
            constant_type = CONSTANT_TYPES[tag]
            constant_type.set(constant_pool, no, io) if constant_type
            no += 1 if tag == 5 || tag == 6
            no += 1
          end
        end

        def pull_list(io, type)
          fields_count = io.read(2).unpack('n')[0]
          items = []
          if fields_count > 0
            fields_count.times do
              access_flags, name_index, descriptor_index = io.read(6).unpack('n*')
              attributes = pull_attributes(io)
              item = type.new(constant_pool[descriptor_index].val, attributes)
              item.access_flags, item.name = access_flags, constant_pool[name_index].val
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
            attributes << {constant_pool[attribute_name_index].val => io.read(attribute_length)}
          end
          attributes
        end
    end


  end
end