#encoding: utf-8
($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../lib' ))).uniq!

require 'pindare'

# Modèle EDO de croissance basé sur Predictive Pharmacokinetic-Pharmacodynamic Modeling of Tumor Growth Kinetics in Xenograft Models after Administration of Anticancer Agents. (2004). Predictive Pharmacokinetic-Pharmacodynamic Modeling of Tumor Growth Kinetics in Xenograft Models after Administration of Anticancer Agents, 1–8.
#
class Model_Simeoni < Model
  include TimeIntegrator

  def post_initialize
    @name="Modèle simple de croissance"
    @vars=@vars0
  end

  # Intégration
  #
  # @param [Float] tps Temps final de l'intégration
  def integrate(tps)

    t=0.0
    dt=0.0005

    hist_TumorMass={}

    ctr=0
    num_iters=tps/dt
    while(t<tps)
      # Sauvegarde éventuelle des observables
      save_observables t, dt if instants

      @vars=ts_RK4( @vars, dt)



      # Calcul des numids
      @numids[:PFS]=t unless (@vars<=@vars0) or @numids.has_key?(:PFS)

      # Sauvegarde de l'historique
      if ctr.modulo(200)==0
        hist_TumorMass[t]=vars
      end


      # Incrément des compteurs
      t+=dt; ctr+=1
    end

    @numids[:FTV]=vars
    @numids[:PFS]=t unless @numids.has_key?(:PFS)

  end

  attr_reader :params, :numids
  private
  attr_reader :instants, :saved_obs, :vars

  # Fonction principale d'évolution (y'=func(y))
  #
  def func(v)
    lambda0=params[:lambda0]
    psi=params[:psi]
    lambda0*v/(1.0+(lambda0/params[:lambda1]*v)**psi)**(1.0/psi)
  end
end


pmap={psi: 1.0, lambda0: 1.0, lambda1: 1.0}
w_init=1.0
model=Model_Simeoni.new(pmap, w_init)
model.integrate(20.0,false)
#puts model.numids
