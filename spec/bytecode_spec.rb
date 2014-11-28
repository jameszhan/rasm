describe Rasm do

  describe 'Bytecode' do
    it 'it can analyze java class bytecode' do
      root_dir = '/u/workdir/codes/rfsc/codegen/target/test-classes'
      clazz = 'com.mulberry.athena.asm.DemoClass'


      class_file = "#{root_dir}/#{clazz.gsub('.', '/')}.class"

      bytecode = Rasm::Java::Bytecode.new class_file
      puts bytecode.version
      puts bytecode.constant_pool_count
      puts bytecode.cp_info
      puts bytecode.class_info
      puts bytecode.fields
      puts bytecode.methods
      puts bytecode.attributes
    end
  end

end