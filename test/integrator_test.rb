($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../lib' ))).uniq!

require 'integrator'
require 'narray'

require 'minitest/autorun'


class ExpModel
    include TimeIntegrator

    def initialize(params, init)
        @params=params
        @vars0=init ; @vars0.freeze
        @vars=init
    end


    def func(v)
        vect=NArray.float(v.size)

        vect[0]=@params[:alpha]*v[0]
        vect[1]=-@params[:alpha]*v[1]

        vect
    end
end

describe TimeIntegrator do
    before :each do
        @v=NArray.float(2).fill!(0.01)
    end

    describe "when solving explicitely" do
        it "will solve accurately" do
            params={:alpha=>0.01}
            e_exp=ExpModel.new(params,@v)

            def e_exp.integrate(tps)
                t=0.0
                dt=0.005

                while(t<=tps)
                    # Résolution du pb
                    @vars=ts_euler_explicit( @vars, dt)
                    t+=dt
                end
                [@vars[0], @vars[1]]
            end
            v0, v1=e_exp.integrate(100.0)
            v0.must_be_close_to Math::exp(100.0*params[:alpha])*@v[0], 1e-6
            v1.must_be_close_to Math::exp(-100.0*params[:alpha])*@v[1], 1e-6
        end
    end

    describe "when solving with RK2" do
        it "will solve accurately" do
            params={:alpha=>0.01}
            e_exp=ExpModel.new(params,@v)

            def e_exp.integrate(tps)
                t=0.0
                dt=0.005

                while(t<tps)
                    # Résolution du pb
                    @vars=ts_RK2( @vars, dt)
                    t+=dt
                end
                [@vars[0], @vars[1]]
            end

            v0, v1=e_exp.integrate(100.0)
            v0.must_be_close_to Math::exp(100.0*params[:alpha])*@v[0], 1.4e-6
            v1.must_be_close_to Math::exp(-100.0*params[:alpha])*@v[1], 1.4e-6
        end
    end

    describe "when solving with RK4" do
        it "will solve accurately" do
            params={:alpha=>0.01}
            e_exp=ExpModel.new(params,@v)

            def e_exp.integrate(tps)
                t=0.0
                dt=0.005

                while(t<tps)
                    # Résolution du pb
                    @vars=ts_RK4( @vars, dt)
                    t+=dt
                end
                [@vars[0], @vars[1]]
            end

            v0,v1=e_exp.integrate(100.0)
            v0.must_be_close_to Math::exp(100.0*params[:alpha])*@v[0], 1.4e-6
            v1.must_be_close_to Math::exp(-100.0*params[:alpha])*@v[1], 1.4e-6
        end
    end

end
