require "typed-array/functions"

# This module is useful for creating Array subclasses that enforce
# the types of objects it acepts.
# 
# There are two general forms:
#
# class Things < Array
#   extend TypedArray
#   restricted_types Thing1, Thing2
#   # ...
# end
# things = Things.new()
# 
# or
# 
# things = TypedArray(Thing1,Thing2).new
#
# We attempt to ensure that validation occurs *before* any changes are made
# to the TypedArray in question. 
# If validation fails, TypedArray::UnexpectedTypeException is raised.
module TypedArray

  # Hook the extension process in order to include the necessary functions
  # and do some basic sanity checks.
  def self.extended( mod )
    unless mod <= Array
      raise UnexpectedTypeException.new( [Array], mod.class )
    end
    mod.module_exec(self::Functions) do |functions_module|
      include functions_module
    end
  end

  # when a class inherits from this one, make sure that it also inherits
  # the types that are being enforced
  def inherited( subclass )
    self._subclasses << subclass
    subclass.restricted_types *restricted_types
  end

  # A getter/setter for types to add. If no arguments are passed, it simply
  # returns the current array of accepted types.
  def restricted_types(*types)
    @_restricted_types ||= []
    types.each do |type|
      raise UnexpectedTypeException.new([Class],type.class) unless type.is_a? Class
      @_restricted_types << type unless @_restricted_types.include? type
      _subclasses.each do |subclass|
        subclass.restricted_types type
      end
    end
    @_restricted_types
  end; alias :restricted_type :restricted_types

  class UnexpectedTypeException < Exception
    attr_reader :expected, :received

    def initialize expected_one_of, received
      @expected = expected_one_of
      @received = received
    end

    def to_s
      %{Expected one of #{@expected.inspect} but received a(n) #{@received}}
    end
  end
  
  protected
    
  # a store of subclasses
  def _subclasses
    @_subclasses ||= []
  end
    
end

# Provide a factory
#
def TypedArray *types_allowed
  klass = Class.new( Array )
  klass.class_exec(types_allowed) do |types_allowed|
    extend TypedArray
    restricted_types *types_allowed
    restricted_types
  end
  klass.restricted_types
  klass
end
