($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../lib' ))).uniq!
require 'observable'
require 'gradient'
require 'model'
require 'integrator'
require 'params'
require 'narray'

require 'minitest/autorun'



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

describe 'when there is one parameter' do
  it 'should converge with a linear model and random seed' do
    # Observable
    obs_ref = Observable.new("No Name", {0.0 =>0.0, 2.0 => 1.0})

    Linear_Model=TestModel.dup
    class Linear_Model
      def func vv
        @params[:alpha]
      end
    end

    # Parametres
    params=ParamsSet.new ( {:alpha => rand(1.0)})

    gg=Sensitivity.new({:obs=>obs_ref, :model_class=>Linear_Model, :init_cond=>0.0, :params0=>params, :control_set=>[:alpha], :tmax=>2.1, :max_its=>10000},FileLogger.new("./log_linear.txt"))

    err,pp = gg.gradient(1e-3)

    err.must_be_close_to 0.0, 1e-3
    pp[:alpha].must_be_close_to 0.5, 1e-3
  end

  it 'should converge with an exponential model and random seed' do
    # Observable
    obs = Observable.new("No Name", {0.0=>1.0, 1.0 =>Math::exp(0.5),  2.0 => Math::exp(1.0)})

    Exp_Model=TestModel.dup
    class Exp_Model
      def func vv
        @params[:alpha]*vv
      end
    end

    # Parametres
    params=ParamsSet.new ( {:alpha => rand(1.0)})

    gg=Sensitivity.new({:obs=>obs, :model_class=>Exp_Model, :init_cond=>1.0,:params0=>params, :control_set=>[:alpha], :tmax=>2.1, :max_its=>50000},FileLogger.new("./log_exp.txt"))

    err,pp = gg.gradient(1e-5)
    err.must_be_close_to 0.0, 1e-5
    pp[:alpha].must_be_close_to 0.5, 1e-3

  end
end
end
