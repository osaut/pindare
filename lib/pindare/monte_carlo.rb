#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'params'
require 'celluloid'

# Unité de calcul (thread)
class CoreUnit
  include Celluloid

  def initialize num_computations, data
    @num_computations=num_computations
    @evaluator_class = data.fetch(:model_class)
    @data_sim=data.fetch(:data_sim)
    @recompute_init=data.fetch(:recompute_init) { false }
    @params_ranges=data.fetch(:params_ranges)
    @fixed_params=data[:fixed_params]
  end

  # Lancement du calcul effectif
  def work

    hist={}
    best_fitness=1e150
    best_candidate={}

    num_computations.times do
      # Tirage des paramètres
      params=random_params @params_ranges

      # Setup du calcul
      data_sim[:init_values]=calc_init_data params
      model=evaluator_class.new(data_sim, params)

      # Lancement
      model.run

      # Exploitation des résultats
      hist[params]=model.numids
      fitness=model.fitness

      if fitness < best_fitness
        best_fitness = fitness
        best_candidate=params.dup
      end
    end

    [best_fitness, best_candidate, hist]
  end

private
  # Tirage d'un jeu de paramètres aléatoires dans l'espace des paramètres
  # @param [Hash] pranges Intervalles de variation des paramètres
  # @return [ParamsSet] Jeu de paramètre aléatoire
  def random_params pranges
    # Construction de la liste des paramètres
      params_hash={}
      pranges.each do |pp, rr|
        params_hash[pp]=rr.min+rand*(rr.max-rr.min)
      end
      params_hash.merge(@fixed_params)
      ParamsSet.new params_hash
  end

  # Calcul des données initiales éventuelllement dépendant des paramètres
  # @param [ParamsSet] params Jeu de paramètres
  # @return
  def calc_init_data params
    return data_sim.fetch(:init_values) unless @recompute_init
    data_sim.fetch(:init_values).merge(evaluator_class.calc_init_data_from_obs(data_sim.fetch(:obs)[:Y], params))
  end


  attr_reader :num_computations, :data_sim, :evaluator_class
end

#
# Monte Carlo
#
class Monte_Carlo
  def initialize data, logger=nil
    @data=data
    @logger=logger
    @num_its=data.fetch(:num_its) {10000}
  end

  def run
    pool=CoreUnit.pool(size: data.fetch(:pool_size){Celluloid.cores}, args:[data.fetch(:jobs_per_core){4},data])
    size_pool=pool.size

    history={}
    best_fitness=1.0/0.0 ; best_candidate=nil

    num_its.times do |ctr|

      # Lancement de tous les calculs
      futures=(1..size_pool).to_a.map { |cpu| pool.future.work}
      res_cores=futures.map(&:value)

      it_candidate=res_cores.min{ |a,b| a.first <=> b.first}


      if it_candidate.first < best_fitness
        best_fitness = it_candidate.first
        best_candidate=it_candidate[1].dup
      end

      logger.record({:it=>ctr, :best_fitness=>best_fitness, :params=>best_candidate}) if logger
    end

    [best_candidate, history]
  end

  private

  attr_reader :logger, :data, :num_its
end
