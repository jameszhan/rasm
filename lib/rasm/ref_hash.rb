
module Rasm

  class Ref
    attr_reader :scope, :selector, :options
    def initialize(scope, selector, options = {})
      @scope = scope
      @selector = selector
      @options = options
    end

    def to_s
      prefix = options[:prefix] || '#'
      if selector.is_a? Array
        split = options[:split] || ':'
        selector.map{|item| "#{prefix}#{item}"}.join(split)
      else
        "#{prefix}#{selector}"
      end
    end

    def val
      split = options[:split] || ':'
      if selector.respond_to? :map
        selector.map{|item| find(scope, item) }.join(split)
      else
        find(scope, selector)
      end
    end

    private
      def find(scope, selector)
        key = options[:key]
        value = scope[selector]
        if value
          ref = key ? value[key] : value
          if ref && ref.respond_to?(:val)
            ref.val
          else
            ref
          end
        end
      end
  end


  class RefHash < Hash

    def ref(selector, options = {})
      Ref.new(self, selector, options)
    end

    def respond_to_missing?(method, *)
      self.include?(method) || super
    end

    def method_missing(method, *args)
      return self[method] if args.empty? && self.include?(method)
      super
    end

  end

end