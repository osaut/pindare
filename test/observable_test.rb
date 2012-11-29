($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../lib' ))).uniq!

require 'observable'
require 'narray'
require 'minitest/autorun'

describe Observable do
  before :each do
    h={}
    (0..20).each do |i|
      h[i*0.1]=(i*0.1)**2
    end
    @obs=Observable.new('Square',h)
  end

describe "When asked about its name" do
  it "will answer correctily" do
    @obs.name.must_equal "Square"
  end
end

describe "When asked about its data" do
  it "will report the number of observations" do
    @obs.size.must_equal 21
  end

  it "will be have stored the data" do
     hh={}
      (0..20).each do |i|
        hh[i*0.1]=(i*0.1)**2
      end
      @obs.data.must_equal hh
  end

  it "will compute the L2 norm" do
    @obs.norm.must_equal 8.500976414506749
  end
end

  describe "When applying operators" do
    it "should compute -" do
      obs2=@obs.dup
      (@obs-obs2).norm.must_equal 0.0
    end

    it "should computed dot_product" do
        hh = Hash[ @obs.data.map{ |key,value| [key, 0.0] } ]
        obs2=Observable.new("Null", hh)
        @obs.dot_product(obs2).must_equal 0.0
    end
  end

  describe "When comparing observables" do
    it "won't be far from itself" do
      hh=@obs.data.dup
      obs2=Observable.new("double_self",hh)
      @obs.dist_L2(obs2).must_equal 0.0
      @obs.dist_L2_relative(obs2).must_equal 0.0
    end

    it "won't accept incompatible observables" do
      hh=@obs.data.dup
      hh.delete(hh.keys.sample(1)[0])
      obs2=Observable.new("bogus",hh)
      lambda {@obs.dist_L2(obs2)}.must_raise(ArgumentError)
      lambda {@obs.dist_L2_relative(obs2)}.must_raise(ArgumentError)
    end

    it "will compute their distance (absolute)" do
      hh = Hash[ @obs.data.map{ |key,value| [key, Math::sqrt(value)] } ]
      obs2=Observable.new("Linear", hh)
      @obs.dist_L2(obs2).must_equal 3.5730379231124885
    end

      it "will compute their distance (relative)" do
      hh = Hash[ @obs.data.map{ |key,value| [key, Math::sqrt(value)] } ]
      obs2=Observable.new("Linear", hh)

      @obs.dist_L2_relative(obs2).must_equal 0.12325884862423606
    end
  end

end
