#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'lib/integrator'
require 'narray'

require 'ruby-progressbar'

#
## Ecriture d'une fonction 1D
#
# @param [String] name Nom du fichier dans lequel on écrit les données
# @param [Hash<FixNum,FixNum>] data_hash Hash sous la forme t=>f(t)
def write_1D_function(name, data_hash)
    pfo=File.new("#{name}.txt",File::CREAT | File::TRUNC | File::WRONLY)

    data_hash.sort.map {|key,value|
        pfo.puts "#{key}\t#{value}"
    }
    pfo.close
end



# Modèle EDO de GIST
#
class Model_GIST
    include TimeIntegrator

    # Initialisation
    #
    # @param [Hash<Symbol, FixNum>] params Paramètres du modèle
    # @param [Array, NArray] init_values Valeurs initiales
    def initialize(params, init_values)
        @params=params.dup.freeze
        @vars=init_values
        @vars0=init_values.dup.freeze  # Pour conserver les valeurs initiales
        @numids={}

    end

    # Intégration
    #
    # @param [FixNum] tps Temps final de l'intégration
    def integrate(tps, progress=true)

        t=0.0
        dt=0.05

        pb=ProgressBar.create(:title=>"Progression") if progress

        hist_P1={}
        hist_P2={}
        hist_M={}

        ctr=0
        num_iters=tps/dt
        while(t<tps)
            # Résolution du pb
            @vars=ts_RK4( @vars, dt)

            # Calcul des numids
            @numids[:PFS]=t unless (@vars[0]+@vars[1]<=@vars0[0]+@vars0[1]) or @numids.has_key?(:PFS)

            # Sauvegarde de l'historique
            if ctr.modulo(200)==0
                hist_P1[t]=@vars[0]
                hist_P2[t]=@vars[1]
                hist_M[t]=@vars[2]
            end

            # Affichage de la barre de progression
            pb.increment if ctr.modulo(num_iters/100)==0 and progress

            # Incrément des compteurs
            t+=dt; ctr+=1
        end

        @numids[:FTV]=@vars[0]+@vars[1]
        @numids[:P1V]=@vars[0]
        @numids[:P2V]=@vars[1]
        @numids[:PFS]=t unless @numids.has_key?(:PFS)

        write_1D_function("P1", hist_P1)
        write_1D_function("P2",hist_P2)
        write_1D_function("M",hist_M)

    end


    attr_reader :params, :numids
private
    # Fonction principale d'évolution (y'=func(y))
    #
    # @param [NArray] v Vecteur auquel on applique la fonction
    def func(v)
        vect=NArray.float(v.size)
        # Ici v[0]=P1, v[1]=P2, v[2]=M
        gammaP=gamma_prolif(v[2])
        growth_factor=gammaP-gamma_necro(v[2])
        vect[0]=(growth_factor-params[:delta]*v[2])*v[0]
        vect[1]=growth_factor*v[1]
        vect[2]=params[:alpha]*(1.0-gammaP/params[:gamma0])*(v[0]+v[1])**(2.0/3.0)-params[:beta]*v[2]*(gammaP/params[:gamma0])*(v[0]+v[1])

        vect
    end

    # Facteur de prolifération
    #
    # @param [FixNum] m Densité de micro-vaisseaux
    # @return [FixNum] taux de prolifération
    def gamma_prolif(m)
        params[:gamma0]*0.5*(1.0+Math::tanh(5.0*(m-params[:Mhyp])))
    end

    # Facteur de nécrose
    #
    # @param [FixNum] m Densité de micro-vaisseaux
    # @return [FixNum] taux de nécrose
     def gamma_necro(m)
        params[:gamma1]*0.5*(1.0+Math::tanh(5.0*(params[:Mhyp]-m)))
    end

end



#
## Initialisation des paramètres
#
pmap={}
pmap[:gamma0]=0.01*70.5
pmap[:gamma1]=0.01*0.71
pmap[:delta]=0.0103471*9.0
pmap[:beta]=0.0115803/3.0
pmap[:Mhyp]=0.6
pmap[:alpha]=0.0005684*0.15*3.05
pmap[:Pourc]=1-0.99999995

#
## Données initiales
#
v_init=NArray.float(3)
Surface=460.0
v_init[0]=Surface*(1.0-pmap[:Pourc]) ; v_init[1]=Surface*pmap[:Pourc] ; v_init[2]=0.3



#
## Intégration du modèle de GIST
model=Model_GIST.new(pmap, v_init)
model.integrate(800.0)
puts model.numids
