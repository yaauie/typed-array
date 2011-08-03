require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


# We need to test in several different contexts, so provide the base info here.
inputs = {
  [Symbol]=>{
    :base => [:foo,:bar],
    :match => [:baz,:bingo],
    :fail => {
      :one => [:zip,0],
      :all => ['string',Class]
    }
  },
  [Fixnum] => {
    :base => [ 1,2,3 ],
    :match => [ 17,18,19 ],
    :fail => {
      :one => [22,:symbol,43],
      :all => ['string',:symbol]
    }
  },
  [String,Symbol] => {
    :base => ['Foo',:foo],
    :match => [:bar,'Bar'],
    :fail => {
      :one => [:yippee,'a stirng',17],
      :all => [12,Class,Array]
    }
  }
}

describe TypedArray do
  describe '#new' do
    inputs.each_pair do |accepted_types, config|
      context "when only accepting <#{accepted_types.inspect}>" do
        subject { TypedArray( *accepted_types ) }
        context 'Form 1: typed_ary.new()' do
          it "should have zero-length" do
            subject.new().length.should == 0
          end
          it "should be empty" do
            subject.new().to_a.should be_empty
          end
        end
        context 'Form 1: typed_ary.new(size)' do
          it "should have the proper length" do
            subject.new(5).length.should == 5
          end

          it "should conatin all nil values" do
            subject.new(5).to_a.should == [nil,nil,nil,nil,nil]
          end
        end
        context 'Form 2: typed_ary.new(size,object)' do
          it "should have the proper length" do
            subject.new(3,config[:match].first).length.should == 3
          end

          it "should conatin the value specified" do
            subject.new(3,config[:match].first).to_a.should == [config[:match].first]*3
          end

          it "should raise when obj is the wrong type" do
            expect{ subject.new( 3, config[:fail][:all].first ) }.to raise_error TypedArray::UnexpectedTypeException
          end
        end
        context 'Form 3: typed_ary.new( ary )' do
          it "should accept when all items match" do
            subject.new(config[:match]).to_a.should == config[:match]
          end
          it "should raise when one object is the wrong type" do
            expect{ subject.new(config[:fail][:one])}.to raise_error TypedArray::UnexpectedTypeException
          end
          it "should raise when more than one object is the wrong type" do
            expect{ subject.new(config[:fail][:all])}.to raise_error TypedArray::UnexpectedTypeException
          end
        end
        context 'Form 4: typed_ary.new(size){|index|block}' do
          it "should populate when block returns the right type" do
            subject.new(config[:match].length){|i| config[:match][i]}.to_a.should == config[:match]
          end

          it "should raise when block returns wrong type once" do
            expect{ subject.new(config[:fail][:one].length){|i| config[:fail][:one][i]} }.to raise_error TypedArray::UnexpectedTypeException
          end

          it "should raise when block returns wrong type more than once" do
            expect{ subject.new(config[:fail][:all].length){|i| config[:fail][:all][i]} }.to raise_error TypedArray::UnexpectedTypeException
          end
        end
      end
    end
  end

  [:<<,:unshift,:push].each do |method|
    context %Q{typed_ary#{('a'..'z').include?(method.to_s[0]) ? '.' : ' '}#{method.to_s} other_ary} do
      inputs.each_pair do |accepted_types,config|
        context "when only accepting <#{accepted_types.inspect}>" do
          before :each do
            @typed_ary = TypedArray( *accepted_types).new(config[:base])
            @ary = config[:base].to_a
          end

          context "when the item being pushed matches (#{config[:match].first})" do
            before :each do
              @item = config[:match].first
            end
            
            it "should return as Array would return" do
              @typed_ary.send(method,@item).to_a.should == @ary.send(method,@item)
            end

            it "should modify the TypedArray as Array would be modified" do
              @typed_ary.send(method,@item)
              @ary.send(method,@item)
              @typed_ary.to_a.should == @ary
            end
          end

          context "when the item being pushed does not match (#{config[:fail][:all].first})" do
            before :each do
              @item = config[:fail][:all].first
            end
            
            it "should raise an exception" do

              expect{ @typed_ary.send(method,@item) }.to raise_error TypedArray::UnexpectedTypeException
            end

            it "should not modify typed_ary" do
              begin
                backup = @typed_ary.to_a
                @typed_ary.send(method,@item)
              rescue TypedArray::UnexpectedTypeException
              ensure
                @typed_ary.to_a.should == backup
              end
            end
            
          end
        end
      end
    end
  end

  [:[]=].each do |method|
    context %Q{typed_ary[idx]= other_ary} do
      inputs.each_pair do |accepted_types,config|
        context "when only accepting <#{accepted_types.inspect}>" do
          before :each do
            @typed_ary = TypedArray( *accepted_types).new(config[:base])
            @ary = config[:base].to_a
          end

          context "when the item being pushed matches (#{config[:match].first})" do
            before :each do
              @item = config[:match].first
            end
            
            it "should return as Array would return" do
              @typed_ary.send(method,4,@item).should == @ary.send(method,4,@item)
            end

            it "should modify the TypedArray as Array would be modified" do
              @typed_ary.send(method,4,@item)
              @ary.send(method,4,@item)
              @typed_ary.to_a.should == @ary
            end
          end

          context "when the item being pushed does not match (#{config[:fail][:all].first})" do
            before :each do
              @item = config[:fail][:all].first
            end
            
            it "should raise an exception" do

              expect{ @typed_ary.send(method,4,@item) }.to raise_error TypedArray::UnexpectedTypeException
            end

            it "should not modify typed_ary" do
              begin
                backup = @typed_ary.to_a
                @typed_ary.send(method,4,@item)
              rescue TypedArray::UnexpectedTypeException
              ensure
                @typed_ary.to_a.should == backup
              end
            end
            
          end
        end
      end
    end
  end


  [:+,:&,:concat,:replace].each do |method|
    context %Q{typed_ary#{('a'..'z').include?(method.to_s[0]) ? '.' : ' '}#{method.to_s} other_ary} do
      inputs.each_pair do |accepted_types,config|
        context "when only accepting <#{accepted_types.inspect}>" do
          before :each do
            @typed_ary = TypedArray( *accepted_types).new(config[:base])
            @ary = config[:base].to_a
          end

          context "when all items match (#{config[:match].inspect})" do
            before :each do
              @other_ary = config[:match].to_a
            end

            it "should return as Array would return" do
              @typed_ary.send(method,@other_ary).to_a.should == @ary.send(method,@other_ary)
            end

            it "should modify the TypedArray as Array would be modified" do
              @typed_ary.send(method,@other_ary)
              @ary.send(method,@other_ary)
              @typed_ary.to_a.should == @ary
            end
          end

          config[:fail].each_key do |fail_type|
            context "when #{fail_type} item fails to match (#{config[:fail][fail_type].inspect})" do
              before :each do
                @other_ary = config[:fail][fail_type].to_a
              end
              unless method == :& # `and` opperator cannot produce elements that are not in both arrays already; since one is assuredly filtered, we can skip this.
                it "should raise an exception" do
                  expect{ @typed_ary.send(method,@other_ary) }.to raise_error TypedArray::UnexpectedTypeException
                end
              end
              it "should not modify the TypedArray" do
                begin
                  backup = @typed_ary.to_a
                  @typed_ary.send(method,@other_ary)
                rescue TypedArray::UnexpectedTypeException
                ensure
                  @typed_ary.to_a.should == backup
                end
              end
            end
          end
        end          
      end
    end
  end

  context 'when extending classes' do
    before :each do
      @base = TypedArray(Symbol)
      @extension = Class.new( @base )
    end

    it 'should inherit default restrictions' do
      @base.restricted_types.should == @extension.restricted_types
    end

    context 'when adding restricted_type to the parent' do
      it 'should propogate to the child' do
        @base.restricted_type Fixnum
        @extension.restricted_types.should include(Fixnum)
      end
    end
    context 'when adding restricted_type to the child' do
      it 'should not propogate to the parent' do
        @extension.restricted_type Fixnum
        @base.restricted_types.should_not include(Fixnum)
      end
    end
    

  end
end
