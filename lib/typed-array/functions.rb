module TypedArray
  module Functions
    def initialize *args, &block
      ary = Array.new *args, &block
      self.replace ary
    end

    def replace other_ary
      _ensure_all_items_in_array_are_allowed other_ary
      super
    end

    def & ary
      self.class.new super
    end

    def * int
      self.class.new super
    end

    def + ary
      self.class.new super
    end

    def << item
      _ensure_item_is_allowed item
      super
    end

    def [] idx
      self.class.new super
    end

    def slice *args
      self.class.new super
    end

    def []= idx, item
      _ensure_item_is_allowed item
      super
    end

    def concat other_ary
      _ensure_all_items_in_array_are_allowed other_ary
      super
    end

    def eql? other_ary
      _ensure_all_items_in_array_are_allowed other_ary
      super
    end

    def fill *args, &block
      ary = self.to_a
      ary.fill *args, &block
      self.replace ary
    end

    def push *items
      _ensure_all_items_in_array_are_allowed items
      super
    end

    def unshift *items
      _ensure_all_items_in_array_are_allowed items
      super
    end

    def map! &block
      self.replace( self.map &block )
    end

    protected

    def _ensure_all_items_in_array_are_allowed ary
      return true if ary.is_a? self.class
      _ensure_item_is_allowed( ary, [Array] )
      ary.each do |item|
        _ensure_item_is_allowed(item)
      end
    end

    def _ensure_item_is_allowed item, expected=nil
      return true if item.nil?
      expected = self.class.restricted_types if expected.nil?
      expected.each do |allowed|
        return true if item.class <= allowed
      end
      raise TypedArray::UnexpectedTypeException.new expected, item.class
    end
  end
end