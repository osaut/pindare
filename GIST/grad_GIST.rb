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

pmap={}
pmap[:gamma0]=1.0001000100009998
pmap[:gamma1]=0.01*0.71
pmap[:delta]=0#0.0103471*9.0
pmap[:beta]=0.0115803/3.0
pmap[:Mhyp]=0.6
pmap[:alpha]=0.0005684*0.15*3.05
pmap[:Pourc]=1-0.99999995


# Observable
# Avec thérapie
obs_th=Observable.new("NBER", {0=>1.0, 3.8=>18.6851733929, 6.8=>10.1022995752, 9=>6.6363631443, 10.8666666667=>6.3900561118,13.3666666667=>5.7660471141,16.2666666667=>4.4055857513,17.6666666667=>4.3688765268,20.2=>4.1835522607,22.7666666667=>4.0372564447,25.7=>8.0528322618,29.4333333333=>96.1124512598})
obs_growth=Observable.new("NBER", {0=>1.0, 3.8=>18.6851733929})

# Paramètres et set de contrôle
params=ParamsSet.new (pmap)
cst=Set.new [ :gamma1]

# Conditions initiales
v_init=NArray.float(3)
v_init[0]=obs_growth[0]*(1.0-pmap[:Pourc])
v_init[1]=obs_growth[0]*pmap[:Pourc]
v_init[2]=0.3

# Contraintes sur les paramètres
constraints={:delta=>0..5.0, :gamma0=>0..1.0, :Mhyp=>0.5..0.6, :alpha=>0..1.0}

gg=Sensitivity.new({:obs=>obs_growth, :model_class=>Model_GIST, :init_cond=>v_init,:params0=>params, :control_set=>cst,
 :tmax=>885, :max_its=>50000, :params_ranges=>constraints}, FileLogger.new("./log_grad_GIST.txt"))

err,pp = gg.gradient(1e-2)
