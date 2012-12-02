($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '.' ))).uniq!
require '/Users/saut/Dropbox/RubyBox/Odysseus/lib/elyse.rb'

require 'GIST'

class AMR_Evaluator
  def initialize arr
    @pmap={}
    @pmap[:gamma0]=arr[0] # 0.01*70.5
    @pmap[:gamma1]=0.01*0.71
    @pmap[:delta]=0.0103471*9.0
    @pmap[:beta]=0.0115803/3.0
    @pmap[:Mhyp]=arr[1] # 0.6
    @pmap[:alpha]=0.0005684*0.15*3.05
    @pmap[:Pourc]=1-0.99999995
  end

  def compute
    surface=460.0
    v_init={:P1=>surface*(1.0-@pmap[:Pourc]), :P2=>surface*@pmap[:Pourc],
     :M=>0.3}
    model=Model_GIST.new(@pmap, v_init)
    model.integrate(800.0,false)
    num_res=model.numids
    num_res[:FTV]/708.6499999999032
  end
end

domain=[[0.200, 0.7], [0.5, 1.0]]
ag=AdaptiveGrid.new(domain, AMR_Evaluator, 0.15)

puts "Saving mesh..."
ag.save_as_polydata("./mesh")
