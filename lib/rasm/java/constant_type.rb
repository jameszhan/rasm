module Rasm
  module Java

    ConstantType = Struct.new(:name, :tag, :rule) do

      def value(val)
        {tag: tag, name: name, val: val}
      end

      def value_at(io)
        rule.call(io)
      end

      class << self
        def val(name, tag, len, flag)
          ConstantType.new(name, tag, val_lambda(name, tag, len, flag))
        end

        def ref(name, tag, len)
          ConstantType.new(name, tag, ref_lambda(name, tag, len))
        end

        private
          def val_lambda(name, tag, len, flag)
            lambda do|io|
              length = len.respond_to?(:call) ? len.call(io) : len
              bytes = io.read(length)
              val = flag.respond_to?(:call) ? flag.call(bytes) : bytes.unpack(flag)[0]
              {val: val, name: name, tag: tag}
            end
          end

          def ref_lambda(name, tag, len)
            lambda do|io|
              selector = len == 2 ? io.read(len).unpack('n')[0] : io.read(len).unpack('nn')
              lambda{|cp| cp.ref(selector).bind(name: name, tag: tag)}
            end
          end
      end

    end


    CONSTANT_TYPES = [
      nil,
      ConstantType.val(:Utf8, 1, lambda{|io| io.read(2).unpack('n')[0]}, 'a*'),
      nil,
      ConstantType.val(:Integer ,3, 4, 'N'),
      ConstantType.val(:Float, 4, 4, 'g'),
      ConstantType.val(:Long, 5, 8, lambda{|bytes| h, l = bytes.unpack('NN'); (h << 32) + l}),
      ConstantType.val(:Double, 6, 8, 'G'),
      ConstantType.ref(:Class, 7, 2),
      ConstantType.ref(:String, 8, 2),
      ConstantType.ref(:Fieldref, 9, 4),
      ConstantType.ref(:Methodref, 10, 4),
      ConstantType.ref(:InterfaceMethodref, 11, 4),
      ConstantType.ref(:NameAndType, 12, 4)
    ]



  end
end