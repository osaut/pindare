#encoding: utf-8
require 'forwardable'

class ParamsSet
  include Enumerable
  extend Forwardable

  def initialize hh
    @params=hh
  end

  def to_s
    str=""
    params.each do |key,value|
      str << "#{key} = #{ value } ; "
    end
    str
  end

  class << self
    def load_from_file fname

    end
  end

  def save_to_file fname
    JSON::dump(params,File.new(fname, 'w'))
  end

  # Délégations
  def_delegators :@params, :[], :size, :each

  private
  # Accesseurs
  attr_reader :params

end
