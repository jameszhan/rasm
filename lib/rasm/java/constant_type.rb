module Rasm
  module Java

    ConstantInfo = Struct.new(:name, :tag, :val, :bytes) do
      def to_s
        val
      end
    end

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
        cp[key] = val.is_a?(Rasm::Ref) ? val.bind(tag: tag, name: name) : ConstantInfo.new(name, tag, val)
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

  end
end