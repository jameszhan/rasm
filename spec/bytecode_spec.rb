describe Rasm do

  describe 'Bytecode' do
    it 'it can analyze java class bytecode' do
      root_dir = '/u/workdir/codes/rfsc/codegen/target/test-classes'
      clazz = 'com.mulberry.athena.asm.DemoClass'


      class_file = "#{root_dir}/#{clazz.gsub('.', '/')}.class"

      class_node = Rasm::Java::Bytecode.of class_file
      puts class_node.version
      # puts bytecode.cp_info
      puts class_node
      puts class_node.field_nodes
      puts class_node.method_nodes
      puts class_node.attributes
    end
  end

end