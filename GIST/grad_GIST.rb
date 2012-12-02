$LOAD_PATH.unshift(File.dirname(__FILE__))
require '../lib/pindare'
require 'GIST'
require 'set'

class FileLogger
  def initialize fname
    @file_name=fname
    File.new(fname, File::CREAT | File::TRUNC)
    @ctr=500
  end

  def record hh
    puts "#{hh[:it]} : #{hh[:err]} (#{hh[:params]})"
    if(@ctr==500)
      File.open(@file_name,'a') do |f|
        f.puts "#{hh[:it]}\t#{hh[:err]}\t#{hh[:params]}"
      end
      @ctr=0
    else
      @ctr+=1
    end
  end
end

# Paramètres d'origine
pmap={}
# pmap[:gamma0]=1.0001000100009998
# pmap[:gamma1]=0.01*0.71
# pmap[:delta]=0#0.0103471*9.0
# pmap[:beta]=0.0115803/3.0
# pmap[:Mhyp]=0.6
# pmap[:alpha]=0.0005684*0.15*3.05
pmap[:Pourc]=1-0.99999995

# Paramètres de croissance
pmap[:gamma0] = 0.9091894564415575
pmap[:gamma1] = 0.0070999999999999995
pmap[:delta] = 0
pmap[:beta] = 0.0038601
pmap[:Mhyp] = 0.570513031289482
pmap[:alpha] = 0.9393061617902937
pmap[:Pourc] = 5.000000002919336e-08 ;

# Observable
# Avec thérapie
obs_th=Observable.new("NBER", {0=>18.6851733929, 3.0=>10.1022995752, 5.2=>6.6363631443, 7.066666666700001=>6.3900561118,9.566666666700002=>5.7660471141,12.4666666667=>4.4055857513,13.866666666699999=>4.3688765268,16.4=>4.1835522607,18.9666666667=>4.0372564447,21.9=>8.0528322618,25.633333333299998=>96.1124512598})
obs_growth=Observable.new("NBER", {0=>1.0, 3.8=>18.6851733929})

# Paramètres et set de contrôle
params=ParamsSet.new (pmap)
cst=Set.new [ :delta, :Pourc]

# Conditions initiales
surface=obs_th[0]
v_init={:P1=>surface*(1.0-pmap[:Pourc]), :P2=>surface*pmap[:Pourc],
     :M=>0.3}
# v_init[0]=obs_growth[0]*(1.0-pmap[:Pourc])
# v_init[1]=obs_growth[0]*pmap[:Pourc]
# v_init[2]=0.3
#v_init[0]=obs_th[0]*(1.0-pmap[:Pourc])
#v_init[1]=obs_th[0]*pmap[:Pourc]
#v_init[2]=0.3

# Contraintes sur les paramètres
constraints={:delta=>0..5.0, :gamma0=>0..1.0, :Mhyp=>0.5..0.6, :alpha=>0..1.0, :Pourc=>0..1.0}

gg=Sensitivity.new({:obs=>obs_growth, :model_class=>Model_GIST, :init_cond=>v_init,:params0=>params, :control_set=>cst,
 :tmax=>4.0, :max_its=>100000, :recompute_init=>true, :params_ranges=>constraints}, FileLogger.new("./log_grad_GIST.txt"))

err,pp = gg.gradient(1e-2)
