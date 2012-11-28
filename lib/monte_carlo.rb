#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'params'

class Monte_Carlo
  def initialize data, logger=nil
    @evaluator_class = data.fetch(:model_class)
    @params_ranges=data.fetch(:params_ranges)
    @logger=logger
    @num_its=data.fetch(:num_its) {10000}
  end

  def run
    history={}

    num_its.times do |ctr|
      # Construction de la liste des paramètres
      params_hash={}
      params_ranges.each do |pp, rr|
        params_hash[pp]=rr.min+rand(rr.max-rr.min)
      end

      params=ParamsSet.new params_hash

      model=evaluator_class.new(params)
      history[params]=model.run

      logger.record({:it=>ctr, :params=>params, :res=>history[params]}) if logger
    end

    history
  end

  attr_reader :params_ranges, :logger, :num_its, :evaluator_class
end
