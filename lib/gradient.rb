#encoding: utf-8
require 'set'
$LOAD_PATH.unshift(File.dirname(__FILE__))

class Sensitivity

  def initialize data, logger=nil
    @obs_ref=data.fetch(:obs)
    @model_class=data.fetch(:model_class)
    @params0=data.fetch(:params0)
    @init_data=data.fetch(:init_cond)
    @recompute_init_data=data.fetch(:recompute_init) { false }
    @cset=data.fetch(:control_set)
    @tmax=data.fetch(:tmax)
    @instants={:Y => @obs_ref.instants}
    @params_ranges=data.fetch(:params_ranges) { Hash.new }
    @logger=logger
    @max_its=data.fetch(:max_its) {10000}
  end

# Calcul de la sensitivité approchée
# @param [Float] tol Tolérance sur l'erreur
# @return [Array<Float, ParamsSet>] Erreur et jeu de paramètres final
  def gradient(tol)
    params=params0.dup
    scal=1.0

    # Intégration initiale
    v_0=calc_init_data(params)
    model=model_class.new(params0, v_0, instants)
    model.integrate(tmax)
    obsc=model.get_observable(:Y)
    err=obsc.dist_L2_relative(obs_ref)
    err_old=err

    # Boucle principale
    ctr=0
    while(err>tol) and (ctr < @max_its) do
      err_old=err
      # Calcul des dérivées partielles
      grad={}
      cset.each do |param|
        #puts "\t#{param}"
        dp, new_value=diff_param(obsc, model_class, params, param, init_data, tmax, 5e-4)

        grad[param]=calc_gradient(obs_ref, obsc, dp)+1e-5*new_value
        #p grad
      end

      # Calcul des nouvelles valeurs des paramètres
      params_old=params.dup
      params=update_params(params,cset,grad,err, scal)

      # Recalcul de l'erreur
      v_0=calc_init_data(params)
      modelc=model_class.new(params,v_0, instants)
      modelc.integrate(tmax)
      obsc=modelc.get_observable(:Y)
      err=obsc.dist_L2_relative(obs_ref)

      # Si on fait augmenter l'erreur
      if err>err_old
        scal/=2.0
        params=params_old.dup
      end

      logger.record({:it=>ctr, :err=>err, :params=>params}) if logger

      ctr+=1
    end
    [err,params]
  end

  attr_reader :model_class, :obs_ref, :cset, :init_data, :params0,:tmax, :instants, :logger, :params_ranges

  # Calcul de la DP selon un paramètre
  # @param [Observable] obsc Observable calculé avec les paramètres courants
  # @param [Class] mod_class Classe du modèle à intégrer
  # @param [ParamsSet] params Paramètres du modèle
  # @param [String] pp Paramètre que l'on fait varier
  # @param [NArray] init_data Condition initiale
  # @param [Float] tmax Temps final de l'intégration
  # @param [Float] step Pas
  # @return [Array<Observable, double] Observable correspondants à la différence et valeur du paramètre
  def diff_param obsc, mod_class, params, pp, init_data, tmax, step
    l_params=params.dup
    old_value=l_params.fetch(pp)

    l_params[pp]= (old_value!=0) ? (1.0+step)*old_value : step
    diff_pp=l_params[pp]-old_value
    fail if diff_pp==0.0

    model2=mod_class.new(l_params,init_data, instants)
    model2.integrate(tmax)
    obs1=model2.get_observable(:Y)
    [(obs1-obsc)*(1.0/(diff_pp)), l_params[pp]]
  end

  # Calcul du gradient
  # @param [Observable] obs_patient Observable de référence
  # @param [Observable] obs_calc Observable calculé par le modèle avec les paramètres courants
  # @param [Observable] obs_dp Différence entre l'observable calculé et celui calculé avec la perturbation du paramètre
  # @return [Float] Terme correspondant du gradient
  def calc_gradient obs_patient, obs_calc, obs_dp
    err=obs_calc-obs_patient
    obs_dp.dot_product(err)
  end

  # Mise à jour des paramètres après calcul du gradient
  # @param [ParamsSet] params Paramètres d'origine
  # @param [Array<String>] control_set Set de contrôle (paramètres que l'on fait varier)
  # @param [Hash<String, Float>] gradient Gradient de l'erreur en fonction des paramètres
  # @param [Float] err Erreur courante (pour adapter le pas)
  # @return [Hash<String, Float] Nouveau jeu de paramètre
  def update_params params, control_set, gradient, err, scal
    pas=Math::sqrt(err)*0.01/(1.0+Math::sqrt(err))
    control_set.each do |p|
      new_value=params[p]-scal*pas*gradient[p]

      if params_ranges[p]
        if params_ranges[p].include?(new_value)
          params[p]=new_value
        else
          params[p]=(new_value>=params_ranges[p].max) ? 0.5*(params[p]+params_ranges[p].max) : 0.5*(params[p]+params_ranges[p].min)
        end
      end

    end
    params
  end

  # Calcul des données initiales éventuelllement dépendant des paramètres
  # @param [ParamsSet] params Jeu de paramètres
  # @return
  def calc_init_data params
    return init_data unless recompute_init?

    @model_class.calc_init_data_from_obs(@obs_ref, params).merge(init_data)
  end

  def recompute_init?
    @recompute_init_data
  end
end


