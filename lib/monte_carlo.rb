#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'params'

class Monte_Carlo
  def initialize data, logger=nil
    @evaluator_class = data.fetch(:model_class)
    @data_sim=data.fetch(:data_sim)
    @params_ranges=data.fetch(:params_ranges)
    @logger=logger
    @fixed_params=data[:fixed_params]
    @num_its=data.fetch(:num_its) {10000}
  end

  def run
    history={}
    best_fitness=1.0/0.0 ; best_candidate=nil

    num_its.times do |ctr|
      # Construction de la liste des paramètres
      params_hash={}
      params_ranges.each do |pp, rr|
        params_hash[pp]=rr.min+rand*(rr.max-rr.min)
      end
      params_hash.merge(@fixed_params)
      params=ParamsSet.new params_hash

      model=evaluator_class.new(data_sim, params)
      model.run
      history[params]=model.numids
      fitness=model.fitness

      if fitness < best_fitness
        best_fitness = fitness
        best_candidate=params.dup
      end

      logger.record({:it=>ctr, :best_fitness=>best_fitness, :params=>best_candidate, :res=>history[best_candidate]}) if logger
    end

    [best_candidate, history]
  end

  attr_reader :params_ranges, :logger, :num_its, :evaluator_class, :fitness, :data_sim
end
