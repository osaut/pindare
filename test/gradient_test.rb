($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../lib' ))).uniq!
require 'observable'
require 'gradient'
require 'model'
require 'integrator'
require 'params'
require 'narray'

require 'minitest/autorun'
require 'minitest/pride'



describe Sensitivity do
  before :each do
    class TestModel < Model
      include TimeIntegrator
      def post_initialize
        @name="Test Model"
      end

      def integrate tps
        dt=0.05
        t=0
        @v=@vars0
        while t<tps
          save_observables t, dt if instants
          @v=ts_RK4( @v, dt)

          t=t+dt
        end
      end

      def calc_obs symb
        case symb
        when :Y
            @v
        else
            fail "Symbole inconnu !"
        end
      end

      def func v
        v
      end
    end

    class FileLogger
      def initialize fname
        @file_name=fname
        File.new(fname, File::CREAT | File::TRUNC)
        @ctr=500
      end

      def record hh
        if(@ctr==500)
          File.open(@file_name,'a') do |f|
            f.puts "#{hh[:it]}\t#{hh[:err]}\t#{hh[:alpha]}"
          end
          @ctr=0
        else
          @ctr+=1
        end
      end
    end

  end

describe 'when computing the gradient' do
  it 'should give the right DP (increasing version)' do
    Local_Model=TestModel.dup
    class Local_Model
      def func vv
        @params[:alpha]
      end
    end

    obs=Observable.new({0.0=>0.0, 1.0=>1.0})
    tmax=1.1
    params=ParamsSet.new({:alpha=>1.0})
    init_cond=0.0

    gg=Sensitivity.new({:obs=>obs, :model_class=>Local_Model, :init_cond=>0.0, :params0=>params,
      :control_set=>[:alpha], :tmax=>1.1, :max_its=>1})

    obs_res, new_value=gg.diff_param obs, Local_Model, params, :alpha, init_cond, 1.1, 1.0

    (obs_res-Observable.new({0.0=>0.0, 1.0=>1.0})).norm.must_be_close_to 0, 1e-10
    new_value.must_equal 2.0

  end
  it 'should give the right DP (decreasing version)' do
    Local_Model=TestModel.dup
    class Local_Model
      def func vv
        @params[:alpha]
      end
    end

    obs=Observable.new({0.0=>0.0, 1.0=>-1.0})
    tmax=1.1
    params=ParamsSet.new({:alpha=>-1.0})
    init_cond=0.0

    gg=Sensitivity.new({:obs=>obs, :model_class=>Local_Model, :init_cond=>0.0, :params0=>params,
      :control_set=>[:alpha], :tmax=>1.1, :max_its=>1})

    obs_res, new_value=gg.diff_param obs, Local_Model, params, :alpha, init_cond, 1.1, 1.0

    (obs_res-Observable.new({0.0=>0.0, 1.0=>1.0})).norm.must_be_close_to 0, 1e-10
    new_value.must_equal -2.0

  end
end

describe 'when we fit a linear function (1 parameter)' do
  before :each do
    # Observable
    @obs_ref = Observable.new("No Name", {0.0 =>0.0, 2.0 => 1.0})

    Linear_Model=TestModel.dup
    class Linear_Model
      def func vv
        @params[:alpha]
      end
    end
  end

  it 'should converge when at the solution' do
    # Parametre sur la solution
    params=ParamsSet.new ( {:alpha => 0.5})

    gg=Sensitivity.new({:obs=>@obs_ref, :model_class=>Linear_Model, :init_cond=>0.0, :params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0}, :tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-2)

    err.must_be_close_to 0.0, 1e-2
    pp[:alpha].must_be_close_to 0.5, 1e-2
  end

  it 'should converge when > than the solution' do
    # Parametre un peu au-dessus
    params=ParamsSet.new ( {:alpha => 0.75})

    gg=Sensitivity.new({:obs=>@obs_ref, :model_class=>Linear_Model, :init_cond=>0.0, :params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0}, :tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-2)
    err.must_be_close_to 0.0, 1e-2
    pp[:alpha].must_be_close_to 0.5, 1e-2
  end

  it 'should converge when < than the solution' do
    # Parametre un peu en dessous
    params=ParamsSet.new ( {:alpha => 0.25})

    gg=Sensitivity.new({:obs=>@obs_ref, :model_class=>Linear_Model, :init_cond=>0.0, :params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0}, :tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-2)

    err.must_be_close_to 0.0, 1e-2
    pp[:alpha].must_be_close_to 0.5, 1e-2
  end

  it 'should converge for a random seed' do
    # Parametre aléatoire
    params=ParamsSet.new ( {:alpha => 0.001+rand})

    gg=Sensitivity.new({:obs=>@obs_ref, :model_class=>Linear_Model, :init_cond=>0.0, :params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0}, :tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-2)

    err.must_be_close_to 0.0, 1e-2
    pp[:alpha].must_be_close_to 0.5, 1e-2
  end
  end

  describe 'when we fit an exponential function (1 parameter)' do
    before :each do
      # Observable
      @obs = Observable.new("No Name", {0.0=>1.0, 1.0 =>Math::exp(0.5),  2.0 => Math::exp(1.0)})

      Exp_Model=TestModel.dup
      class Exp_Model
        def func vv
          @params[:alpha]*vv
        end
      end
    end

  it 'should converge when at the solution' do
    # On part sur la solution
    params=ParamsSet.new({:alpha => 0.5})
    gg=Sensitivity.new({:obs=>@obs, :model_class=>Exp_Model, :init_cond=>1.0,:params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0},:tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-5)
    err.must_be_close_to 0.0, 1e-5
    pp[:alpha].must_be_close_to 0.5, 1e-3
  end

  it 'should converge when > than the solution' do
    # On part au dessus
    params=ParamsSet.new({:alpha => 0.75})
    gg=Sensitivity.new({:obs=>@obs, :model_class=>Exp_Model, :init_cond=>1.0,:params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0},:tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-5)
    err.must_be_close_to 0.0, 1e-5
    pp[:alpha].must_be_close_to 0.5, 1e-3
  end

  it 'should converge when < than the solution' do
     # On part en dessous
    params=ParamsSet.new({:alpha => 0.25})
    gg=Sensitivity.new({:obs=>@obs, :model_class=>Exp_Model, :init_cond=>1.0,:params0=>params,
      :control_set=>[:alpha], :params_ranges=>{:alpha=>0.0001..1.0},:tmax=>2.1, :max_its=>200000})

    err,pp = gg.gradient(1e-5)
    err.must_be_close_to 0.0, 1e-5
    pp[:alpha].must_be_close_to 0.5, 1e-3
  end
end
end
