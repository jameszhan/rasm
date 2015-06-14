module Rasm
  module Visitable
    def dispatch(node, type)
      self.send("visit_#{type}".to_sym, node)
    end
  end
end
