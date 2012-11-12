#encoding: utf-8
require 'forwardable'

# Class observable
# Cette classe permet de manipuler tous les observables.
# La structure de base est un Hash t=>obs
#
class Observable
  include Enumerable
  extend Forwardable

  # Accesseurs
  attr_reader :name
  attr_accessor :data

  # Délégations
  def_delegators :@data, :[], :size, :each

  # Constructeur
  #
  # @param [String] name Nom de l'observable
  # @param [Hash] time_sequence Séquence des observations
  def initialize name, time_sequence
    @name=name
    @data=time_sequence.dup
  end


  # Chargement depuis un répertoire
  #
  # @param [String] dirname Nom du répertoire contenant l'observable
  # @return [Observable] Observable
  def self.load_from_dir dirname

  end

  # Chargement depuis un fichier texte
  #
  # @param [String] fname Nom du fichier à charger
  # @return [Observable] Observable
  def self.load_from_file fname
    new_name=File.basename(fname,".txt")
    new_data={}
    File.open(fname, "r") { |line|
      t,y=line.split('\t')
      data[t.to_f]=y.to_f
    }
    Observable.new(new_name,new_data)
  end

  # Norme L2 d'un observable
  # @return [Float] Norme L2
  def norm
    Math::sqrt(data.values.inject(0) { |m,v| m+v**2})
  end


  # Différence de deux observables
  def - other
    new_name="#{name}-#{other.name}"
    new_data={}
    data.each {|key,value|
      new_data[key]=value-other[key]
    }
    Observable.new(new_name,new_data)
  end

  # Produit scalaire
  def dot_product other
    sum=0.0
    data.each {|key,value|
      if value.is_a?(NArray)
        sum+=(value*other[key]).sum
      else
        sum+=value*other[key]
      end
    }
    sum
  end

  # Distance de deux observables (norme L2)
  def dist_L2 other
    raise ArgumentError if other.size != size or other.data.keys != data.keys

    sum=0.0
    data.each { |key,value|
      sum+=(value-other[key])**2
    }
    Math::sqrt(sum)
  end

  # Distance relative de deux observables (norme L2)
  def dist_L2_relative other
    raise ArgumentError if other.size != size or other.data.keys != data.keys
    sum=0.0
    data.each{ |key,value|
      sum+=(value-other[key])**2
    }
    s_norm = norm
    s_norm = 1.0 if norm==0.0
    Math::sqrt(sum)/s_norm
  end

  # Multiplication d'un observable
  # @param [Float] other Scalaire par lequel on multiplie les champs observés
  # @return [Observable] Le nouvel observable rescalé.
  def * other
    raise "Multiplication incompatible !" unless other.is_a?(Float)

    data.each { |key,value|
      data[key]=other*value
    }
    self
  end
end
