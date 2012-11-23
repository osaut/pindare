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
v_init=NArray.float(3)
Surface=460.0
v_init[0]=Surface*(1.0-pmap[:Pourc]) ; v_init[1]=Surface*pmap[:Pourc] ; v_init[2]=0.3



#
## Intégration du modèle de GIST
model=Model_GIST.new(pmap, v_init)
model.integrate(800.0)
puts model.numids
