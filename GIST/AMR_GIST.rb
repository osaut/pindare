($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '.' ))).uniq!
require '/Users/saut/Dropbox/RubyBox/Odysseus/lib/AMR/adaptive_grid.rb'

require 'GIST'

class AMR_Evaluator
  def initialize arr
    @pmap={}
    @pmap={rP2P1: 4.925802013635103 , Pourc: 0.05535728308588666 , delta: 0.1363978765190499 , gamma0: 0.8558502376169754 , Mhyp: 0.661373525734454 , alpha: 4.92711278180055 , gamma1: 0.7699156164260105 , beta: 4.344959920845218  }
    @pmap[:gamma0]=arr[0] # 0.01*70.5
    @pmap[:Mhyp]=arr[1] # 0.6
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
