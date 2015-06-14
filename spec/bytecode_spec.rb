describe Rasm do

  describe 'Bytecode' do
    it 'it can analyze java class bytecode' do
      root_dir = '/u/rebirth/perfect/underlying/target/test-classes'
      clazz = 'me.jameszhan.underlying.compiler.HackingGeneric$C'


      class_file = "#{root_dir}/#{clazz.gsub('.', '/')}.class"

      class_node = Rasm::Java::Bytecode.of class_file, verbose: true
      # puts bytecode.cp_info
      puts class_node.textify
      #puts class_node.field_nodes
      #puts class_node.method_nodes
      #puts class_node.attributes
    end
  end

end