module Rasm
  module Java
    class Sourcify
      include Visitable

      def source_code
        @source_code ||= ''
      end

      def visit(node, type)


        self.accept do|value, type|
          case type
            when :version
              str << "// version #{version}\n"
            when :access_flags
              access = access_flags
              if access & ACC_DEPRECATED != 0
                str << "// DEPRECATED\n"
              end
              str << "// access flags 0x%x\n" % access
            when :signature
              str << "// signature: #{signature}\n" if signature
            when :access_desc
              str << access_desc
            when :name
              str << name
            when :super_name
              str << " extends #{super_name} "
            when :interfaces
              str << ' implements %s {' % interfaces.join(',')
            when :source_file
              str << "\n\t// compiled from: #{source_file}\n"
            when :source_debug
              str << "\n\t// debug info: #{source_debug}\n"
            else
              puts "Ignore #{type}: #{value}"
          end
        end
        str << "\n}"
        str
      end

    end
  end
end
