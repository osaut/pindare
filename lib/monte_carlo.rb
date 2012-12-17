#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'params'

class Monte_Carlo
  def initialize data, logger=nil
    @evaluator_class = data.fetch(:model_class)
    @data_sim=data.fetch(:data_sim)
    @recompute_init=data.fetch(:recompute_init) { false }
    @params_ranges=data.fetch(:params_ranges)
    @logger=logger
    @fixed_params=data[:fixed_params]
    @num_its=data.fetch(:num_its) {10000}
  end

  def run
    history={}
    best_fitness=1.0/0.0 ; best_candidate=nil

    num_its.times do |ctr|

      core_history, fitness=launch_core_sims
      history.merge(core_history)

      if fitness < best_fitness
        best_fitness = fitness
        best_candidate=params.dup
      end

      logger.record({:it=>ctr, :best_fitness=>best_fitness, :params=>best_candidate, :res=>history[best_candidate]}) if logger
    end

    [best_candidate, history]
  end

  private
  # Calcul des données initiales éventuelllement dépendant des paramètres
  # @param [ParamsSet] params Jeu de paramètres
  # @return
  def calc_init_data params
    return data_sim.fetch(:init_values) unless @recompute_init
    data_sim.fetch(:init_values).merge(evaluator_class.calc_init_data_from_obs(data_sim.fetch(:obs)[:Y], params))
  end

  # Tirage d'un jeu de paramètres aléatoires dans l'espace des paramètres
  # @return [ParamsSet] Jeu de paramètre aléatoire
  def random_params
    # Construction de la liste des paramètres
      params_hash={}
      params_ranges.each do |pp, rr|
        params_hash[pp]=rr.min+rand*(rr.max-rr.min)
      end
      params_hash.merge(@fixed_params)
      ParamsSet.new params_hash
  end

  # Lancement d'un ensemble de simulation (sur un core)
  def launch_core_sims
    hist={}
    params=random_params
    data_sim[:init_values]=calc_init_data params
    model=evaluator_class.new(data_sim, params)
    model.run
    hist[params]=model.numids

    [hist,model.fitness]
  end

  attr_reader :params_ranges, :logger, :num_its, :evaluator_class, :fitness
  attr_accessor :data_sim
end
