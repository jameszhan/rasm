module Rasm

  class Ref
    attr_reader :scope, :selector, :options
    def initialize(scope, selector, options = {})
      @scope = scope
      @selector = selector
      @options = options
    end

    def bind(defs)
      data.merge!(defs)
      self
    end

    def [](key)
      data[key]
    end

    def []=(key, value)
      data[key] = value
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

    def respond_to_missing?(method, *)
      data.include?(method) || super
    end

    def method_missing(method, *args)
      return data[method] if args.empty? && data.include?(method)
      super
    end

    private
      def data
         @data ||= {}
      end

      def find(scope, selector)
        value = scope[selector]
        value && value.respond_to?(:val) ? value.val : value
      end
  end

end