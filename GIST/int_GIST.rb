($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '.' ))).uniq!

require 'GIST'
#
## Initialisation des paramètres
#
#
pmap={}
# pmap[:gamma0] = 0.9091894564415575
# pmap[:gamma1] = 0.0070999999999999995
# pmap[:delta] = 0
# pmap[:beta] = 0.0038601
# pmap[:Mhyp] = 0.570513031289482
# pmap[:alpha] = 0.9393061617902937
# pmap[:Pourc] = 5.000000002919336e-08

pmap[:Pourc] = 5.000000002919336e-08
pmap[:gamma0] = 0.95996800383287
pmap[:gamma1] = 0.2243926215191342
pmap[:delta] = 0.7172551256378068
pmap[:beta] = 4.580619793960737
pmap[:Mhyp] = 0.5175796318050375
pmap[:alpha] = 2.4291978451373595


#
## Données initiales
#
surface=18.6851733929 #1.0
v_init={:P1=>surface*(1.0-pmap[:Pourc]), :P2=>surface*pmap[:Pourc],
     :M=>0.3}

#
## Intégration du modèle de GIST
model=Model_GIST.new(pmap, v_init)
model.integrate(25.8, true)
puts model.numids
