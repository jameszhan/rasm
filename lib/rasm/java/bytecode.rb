require '../ref'
require '../core_ext'
require '../java/constant_type'

module Rasm
  module Java

    class Bytecode
      attr_reader :version, :constant_pool_count

      def constant_pool
        @constant_pool ||= {}
      end

      def initialize(class_file)
        open class_file, 'rb' do|io|
          magic = io.read(4).unpack('N')[0]
          if magic == 0xCAFEBABE
            @version = io.read(4).unpack('nn').reverse.join('.')
            @constant_pool_count = io.read(2).unpack('n')[0]
            puts @version
            puts @constant_pool_count

            no = 1
            while no < @constant_pool_count
              tag = io.read(1).unpack('C')[0]
              constant_type = CONSTANT_TYPES[tag]
              if constant_type
                constant_type.set(constant_pool, no, io)
                if tag == 5 || tag == 6
                  no += 1
                end
              end
              no += 1
            end

            constant_pool.each do|i, e|
              puts "\t#%02d = %-16s %-20s %s" % [i, e.name, e, ("//#{e.val}" if e.is_a?(Ref))]
            end

          end
        end
      end
    end

    root_dir = '/u/workdir/codes/rfsc/codegen/target/test-classes'
    clazz = 'com.mulberry.athena.asm.DemoClass$A'


    class_file = "#{root_dir}/#{clazz.gsub('.', '/')}.class"

    Bytecode.new class_file
  end
end