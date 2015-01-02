module Rasm
  module Java
    class AnnotationNode
      TYPE_MAP = {
        s: lambda{|v| %{"#{v}"} },
        e: lambda{|v| "#{v[0]}.#{v[1]}"},
        Z: lambda{|v| v == 0 ? 'false' : 'true'}
      }

      attr_accessor :desc, :values, :options
      def initialize(desc, values, options = {})
        @desc, @values, @options = desc, values, options
      end

      def cast(type, value)
        rule = TYPE_MAP[type.to_sym]
        rule ? rule.call(value) : value
      end

      def textify
        "@#{@desc}(#{values.map do|k, v|
          str = "#{k}="
          if v.empty?
            str << '{}'
          elsif v[0].is_a? Array
            str << "{#{v.map{|_, v| cast(_, v) }.join(', ')}}"
          else
            str << cast(v[0], v[1])
          end
          str
        end.join(', ')})"
      end
    end
  end
end