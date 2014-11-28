module Rasm
  module Java

    module Accessable
      ACC_PUBLIC = 0x0001 # class, field, method
      ACC_PRIVATE = 0x0002 # class, field, method
      ACC_PROTECTED = 0x0004 # class, field, method
      ACC_STATIC = 0x0008; # field, method
      ACC_FINAL = 0x0010; # class, field, method
      ACC_SUPER = 0x0020; # class
      ACC_SYNCHRONIZED = 0x0020; # method
      ACC_VOLATILE = 0x0040; # field
      ACC_BRIDGE = 0x0040; # method
      ACC_VARARGS = 0x0080; # method
      ACC_TRANSIENT = 0x0080; # field
      ACC_NATIVE = 0x0100; # method
      ACC_INTERFACE = 0x0200; # class
      ACC_ABSTRACT = 0x0400; # class, method
      ACC_STRICT = 0x0800; # method
      ACC_SYNTHETIC = 0x1000; # class, field, method
      ACC_ANNOTATION = 0x2000; # class
      ACC_ENUM = 0x4000; # class(?) field inner

      ACC_DEPRECATED = 0x20000; # class, field, method


      TYPES = {
        Z: 'boolean',
        B: 'byte',
        C: 'char',
        S: 'short',
        I: 'int',
        F: 'float',
        J: 'long',
        D: 'double',
        L: lambda{|ref| "#{ref}"},
        '['.to_sym => lambda{|type| "#{type}[]"}
      }

      TYPEPATTERN = /^([ZBCSIFJDL\[])([^;<]*(<[^>]+>)?);?$/

      def typeof(decriptor)
        if m = TYPEPATTERN.match(decriptor)
          type = TYPES[m[1].to_sym]
          if type.respond_to? :call
            type.call(typeof(m[2]))
          else
            type
          end
        else
          decriptor
        end
      end

      def access_desc
        access = access_flags & ~ ACC_SUPER
        str = ''
        str << 'public ' if ((access & ACC_PUBLIC) != 0)
        str << 'private ' if ((access & ACC_PRIVATE) != 0)
        str << 'protected ' if ((access & ACC_PROTECTED) != 0)
        str << 'final ' if ((access & ACC_FINAL) != 0)
        str << 'static ' if ((access & ACC_STATIC) != 0)
        str << 'synchronized ' if ((access & ACC_SYNCHRONIZED) != 0)
        str << 'volatile ' if ((access & ACC_VOLATILE) != 0)
        str << 'transient ' if ((access & ACC_TRANSIENT) != 0)
        str << 'abstract ' if ((access & ACC_ABSTRACT) != 0)
        str << 'strictfp ' if ((access & ACC_STRICT) != 0)
        str << 'synthetic ' if ((access & ACC_SYNTHETIC) != 0)
        str << 'enum ' if ((access & ACC_ENUM) != 0)
        str
      end

      attr_accessor :name, :access_flags

    end

  end
end