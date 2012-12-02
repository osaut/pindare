#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'narray'
require 'ruby-progressbar'

require 'lib/integrator'
require 'GIST'

# Pour les sorties
require 'gnuplot'



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
surface=460.0
v_init={:P1=>surface*(1.0-pmap[:Pourc]), :P2=>surface*pmap[:Pourc],
     :M=>0.3}

#
## Lancement du calcul en batch
#
hist_PFS={}; hist_FTV={}; hist_P1V={}; hist_P2V={} ;
delta_min=0.05#pmap[:delta]/5.0
delta_max=1.0 #5.0*pmap[:delta]

NUM_ITERS=200
(0..NUM_ITERS).each do |i|

    l_pmap=pmap.dup
    new_delta=delta_min+i*(delta_max-delta_min)/(NUM_ITERS-1)
    l_pmap[:delta]=new_delta

    puts "#{i} : delta = #{l_pmap[:delta]}"

    run_status=true
    model=Model_GIST.new(l_pmap, v_init)
    begin
        model.integrate(800.0,false)
    rescue Exception => e
        run_status=false
    end


    if run_status
        # Sauvegarde des indicateurs
        numids=model.numids
        hist_PFS[new_delta]=numids[:PFS]
        hist_FTV[new_delta]=numids[:FTV]/Surface
        hist_P1V[new_delta]=numids[:P1V]/Surface
        hist_P2V[new_delta]=numids[:P2V]/Surface
    end
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|

    plot.title  "Progression Free Survival"
    plot.ylabel "Time"
    plot.xlabel "Delta"


    plot.data << Gnuplot::DataSet.new( [hist_PFS.keys, hist_PFS.values] ) do |ds|
      ds.with = "lines"
      ds.notitle
    end
  end

end

write_1D_function("PFS", hist_PFS)
write_1D_function("FTV", hist_FTV)
write_1D_function("P1V", hist_P1V)
write_1D_function("P2V", hist_P2V)
