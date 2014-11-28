class Hash

  def ref(selector, options = {})
    Rasm::Ref.new(self, selector, options)
  end

  def respond_to_missing?(method, *)
    self.include?(method) || super
  end

  def method_missing(method, *args)
    return self[method] if args.empty? && self.include?(method)
    super
  end

end