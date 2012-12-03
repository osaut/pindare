$LOAD_PATH.unshift(File.dirname(__FILE__))
require '../lib/pindare'
require 'GIST'
require 'set'


class Screen_Logger
  def initialize
    @ctr=5
  end

  def record hh
    if(@ctr==5)
    puts "#{hh[:it]} : [#{hh[:best_fitness]}] #{hh[:res]} (#{hh[:params]}) "
    @ctr=0
    else
      @ctr+=1
    end
  end
end

class Evaluator_GIST
  def initialize data_sims, params
    @obs=data_sims.fetch(:obs)
    instants={:Y=>@obs[:Y].instants}
    @model=Model_GIST.new params, data_sims.fetch(:init_values), instants
    @tmax=data_sims.fetch(:tmax)
    @has_run = false
  end

  def run
    @model.integrate(@tmax)
    @has_run=true
  end

  def numids
    self.run unless @has_run
    @model.numids
  end

  def fitness
    self.run unless @has_run
    if @obs
      @model.get_observable(:Y).dist_L2_relative(@obs[:Y])
    else
      numids[:FTV]
    end
  end

  class << self
        def calc_init_data_from_obs obs_ref, params
          Model_GIST.calc_init_data_from_obs obs_ref, params
        end
    end
end


pranges={:Pourc=>0.0..0.1,:delta=>0.0..10.0, :gamma0=>0.1..1.0, :Mhyp=>0.3..0.8, :alpha=>0..5.0, :gamma1=>0.0..1.0, :beta=>0.0..5.0}
fparams={}
obs_th=Observable.new("NBER", {0=>18.6851733929, 3.0=>10.1022995752, 5.2=>6.6363631443, 7.066666666700001=>6.3900561118,9.566666666700002=>5.7660471141,12.4666666667=>4.4055857513,13.866666666699999=>4.3688765268,16.4=>4.1835522607,18.9666666667=>4.0372564447,21.9=>8.0528322618,25.633333333299998=>96.1124512598})

surface=obs_th.first
Pourc=5.000000002919336e-08
v_init={:P1=>surface*(1.0-Pourc), :P2=>surface*Pourc,:M=>0.3 }

mc=Monte_Carlo.new({:model_class=>Evaluator_GIST, :recompute_init=>true, :params_ranges=>pranges, :fixed_params=>fparams, :data_sim=>{:obs=>{:Y=>obs_th}, :init_values=>v_init, :tmax=>26}}, Screen_Logger.new)
mc.run
