#encoding: utf-8

# Classe abstraite pour les modèles
class Model
  # Initialisation
  #
  # @param [Hash<Symbol, Float>] params Paramètres du modèle
  # @param [Array, NArray] init_values Valeurs initiales
  def initialize(params, init_values, observables=nil)
    @params=params.dup.freeze
    @vars0=init_values.dup  # Pour conserver les valeurs initiales
    @vars=@vars0
    @numids={}
    @instants=observables
    @saved_obs={}
    @name="lorem"
    post_initialize
  end


  # Renvoie l'observable décrit par le symbole
  # @param [Symbol] symb Symbole décrivant l'observable
  # @return [Hash<Float,NArray>] Hash décrivant la séquence temporelle de l'observable
  def get_observable symb
      Observable.new(symb.to_s,saved_obs.fetch(symb) { fail "Symbole inconnu !"})
  end

  # Sauvegarde les observables si l'instant est un de ceux considéré
  #
  # @param [Float] tps Temps courant
  # @param [Float] tol Tolérance sur l'écart en temps
  def save_observables tps, tol
      instants.each do |obs, tt|
          @saved_obs[obs] ||= {}
          tt.each do |t|
              @saved_obs[obs][t] = calc_obs(obs) if t>=tps-tol/2.0 and t<tps+tol/2.0
          end
      end
  end

  attr_reader :name
  protected
  attr_reader :saved_obs, :instants, :vars, :params, :vars0

end
