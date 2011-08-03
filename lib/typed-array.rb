# = typed-array - Gemp provides enforced-type functionality to Arrays
# 
# Copyright (c) 2011 Ryan Biesemeyer
# See LICENSE.txt for details
# 
# Ryan Biesemeyer mailto:ruby-dev@yaauie.com
# 
# == Example
# 
# === Create Standard Class
# 
#  require 'typed-array'
#  class Things < Array
#    extend TypedArray
#    restrict_types Thing1,Thing2
#  end
#  
# === Generate Class using Factory
#  
#  require 'typed-array'
#  things = TypedArray(Thing1,Thing2)
# 
# === Adding items to the Array
#  
#  # All standard Array interfaces are implemented, including block-processing
#  # and variable-number of arguments. For methods that would usually return an
#  # Array, they instead return an instance of the current class (except to_a).
#  #
#  # The difference is that if the method would generate an Array including the
#  # wrong types, TypedArray::UnexpectedTypeException is raised and the call is
#  # aborted before modifying the enforced TypedArray instance.
#  
#  require 'typed-array'
#  symbols = TypedArray(Symbol).new([:foo,:bar,:baz,:bingo])
#  begin
#    integers = TypedArray(Integer).new([1,3,7,2,:symbol])
#  rescue TypedArray::UnexpectedTypeException
#    puts "An error occured: #{$!}"
#  end
# 

require "typed-array/functions"

# Provides TypedArray functionality to a subclass of Array
# when extended in the class's definiton
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

  # The exception that is raised when an Unexpected Type is reached during validation
  class UnexpectedTypeException < Exception
    # Provide access to the types of objects expected and the class of the object received
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

# Provide a factory method. Takes any number of types to accept as arguments
# and returns a class that behaves as a type-enforced array.
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
