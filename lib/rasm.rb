require 'rasm/version'
require 'rasm/core_ext'


module Rasm
  autoload :Ref, 'rasm/ref'

  module Java
    autoload :Bytecode, 'rasm/java/bytecode'
  end
end
