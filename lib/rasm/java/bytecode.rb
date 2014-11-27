require '../ref_hash'

module Rasm
  module Java
    ConstantType = Struct.new(:name, :tag, :length) do
      def read(io)
        len = length
        if length.respond_to? :call
          len = length.call(io)
        end
        io.read(len)
      end

      def set(cp, key, io)
        str = read(io)
        val = case tag
          when 1
            str.unpack('a*')[0]
          when 3
            str.unpack('N')[0]
          when 4
            str.unpack('g')[0]
          when 5
            h, l = str.unpack('NN')
            "#{(h << 32) + l}l"
          when 6
            "#{str.unpack('G')[0]}d"
          when 7, 8
            cp.ref(str.unpack('n')[0])
          when 9, 10, 11
            cp.ref(str.unpack('nn'))
          when 12
            cp.ref(str.unpack('nn'))
          else
            puts "Unsupported tag #{tag}"
        end
        cp[key] = val #combine(val)
      end

      private
        def combine(val)
          {val: val, tag: tag, name: name}
        end
    end

    CONSTANT_TYPES = [
      nil,
      ConstantType.new(:Utf8, 1, lambda{|io| io.read(2).unpack('n')[0]}),
      nil,
      ConstantType.new(:Integer ,3, 4),
      ConstantType.new(:Float, 4, 4),
      ConstantType.new(:Long, 5, 8),
      ConstantType.new(:Double, 6, 8),
      ConstantType.new(:Class, 7, 2),
      ConstantType.new(:String, 8, 2),
      ConstantType.new(:Fieldref, 9, 4),
      ConstantType.new(:Methodref, 10, 4),
      ConstantType.new(:InterfaceMethodref, 11, 4),
      ConstantType.new(:NameAndType, 12, 4)
    ]


    class Bytecode
      attr_reader :version, :constant_pool_count

      def constant_pool
        @constant_pool ||= RefHash.new
      end

      def read(class_file)
        open class_file, 'rb' do|io|
          magic = io.read(4).unpack('N')[0]
          if magic == 0xCAFEBABE
            @version = io.read(4).unpack('nn').reverse.join('.')
            @constant_pool_count = io.read(2).unpack('n')[0]
            puts @version
            puts @constant_pool_count
            cp = RefHash.new
            no = 1
            while no < @constant_pool_count
              tag = io.read(1).unpack('C')[0]
              constant_type = CONSTANT_TYPES[tag]
              if constant_type
                constant_type.set(cp, no, io)
                if tag == 5 || tag == 6
                  no += 1
                end
              end
              no += 1
            end
            cp.each do|i, e|
              val = if e.respond_to?(:val) then e.val else e end
              puts val
#              ref = e[:val]
              #puts "\t#%02d = %-16s %-20s %s" % [i, e[:name], ref, ("//#{ref.val}" if ref.respond_to?(:val))]
              #puts "\t#%02d = %-16s %-20s #{"// #{e.val}" if ref.respond_to?(:val)}" % [i, e, ref]
            end

          end
        end
      end
    end

    root_dir = '/u/workdir/codes/rfsc/codegen/target/test-classes'
    clazz = 'com.mulberry.athena.asm.DemoClass$A'


    class_file = "#{root_dir}/#{clazz.gsub('.', '/')}.class"

    Bytecode.new.read class_file
  end
end