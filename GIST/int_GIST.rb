($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '.' ))).uniq!

require 'GIST'
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
## Intégration du modèle de GIST
model=Model_GIST.new(pmap, v_init)
model.integrate(800.0, true)
puts model.numids
