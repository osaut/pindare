#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

class Sensitivity

  def initialize data
    @obs=data[:obs]
    @model_class=data[:model_class]
    @params0=data[:params0]
    @init_data=@obs[0]
    @cset=data[:control_set]
    @tmax=data[:tmax]
  end


  def gradient(tol)
    params=params0.dup

    # Intégration initiale
    model=model_class.new(params0, init_data)
    obsc=model.get_observable(:Y)
    err=obsc.dist_L2_relative(obs)

    # Boucle principale
    while(err>tol) do

      # Calcul des dérivées partielles
      dp={}
      cset.each do |param|

        dp=diff_param(mod_class, params, param, init_data, tmax)

        grad[param]=calc_gradient(obs, obsp, dp)
      end

      # Calcul des nouvelles valeurs des paramètres
      params=update_params(params,cset,grad)


      # Recalcul de l'erreur
      model=model_class.new(params,init_data)
      new_obs=model.get_observable(:Y)
      err=new_obs.dist_L2_relative(obs)

    end

  end

  private
  attr_reader :model_class, :obs, :cset, :init_data, :params0,:tmax

  # Calcul de la DP selon un paramètre
  def diff_param mod_class, params, pp, step, tmax
    l_params=params.dup

    model=mod_class.new(lparams, init_data)
    model.integrate(tmax)
    obs0=model.get_observable(:Y)

    pp.each {|key,value|
      l_params[key]=value+step
    }

    model2=mod_class.new(lparams,init_data)
    model2.integrate(tmax)
    obs1=model.get_observable(:Y)

    (obs1-obs2)*(1.0/step)
  end

  # Calcul du gradient
  # @param [Observable] obs_patient Observable de référence
  # @param [Observable] obs_calc Observable calculé par le modèle avec les paramètres courants
  # @param [Observable] obs_diff Différence entre l'observable calculé et celui calculé avec la perturbation du paramètre
  # @return [Float] Terme correspondant du gradient
  def calc_gradient obs_patient, obs_calc, obs_diff
    zit=obs_diff-obs_calc
    err=obs_calc-obs_patient
    zit.dot_product(err)
  end

  # Mise à jour des paramètres après calcul du gradient
  # @param [Hash<String,Float>] params_orig Paramètres d'origine
  # @param [Array<String>] control_set Set de contrôle (paramètres que l'on fait varier)
  # @param [Hash<String, Float>] gradient Gradient de l'erreur en fonction des paramètres
  # @return [Hash<String, Float] Nouveau jeu de paramètre
  def update_params params_orig, control_set, gradient
    pp=params.orig.dup
    control_set.each do |p|
      pp[p]+=gradient[p]
    end
    pp
  end
end


