/* Un modèle simple écrit en C++ */
#include <map>
#include <string>
#include <iostream>
#include <math.h>

typedef std::pair<std::string, double> Pair;
typedef std::map<std::string, double> Params;
typedef Params Numids;

double func(Params pmap, double v) {
  return pmap["lambda0"]*v/pow(1.0+pow(pmap["lambda0"]/pmap["lambda1"]*v,pmap["psi"]),1.0/pmap["psi"]);
}


Numids integrate(const Params& params, double w_init, double Tmax) {
  Numids numids;
  numids.insert(Pair("PFS",0.0));
  std::map<double,double> hist_TumorMass;
  double t=0.0; const double dt=0.0005;
  double w=w_init;
  int ctr=0;
  const int num_iters=Tmax/dt;

  while(t<Tmax) {

    const double k1=func(params, w);
    const double k2=func(params,w+0.5*dt*k1);
    const double k3=func(params,w+0.5*dt*k2);
    const double k4=func(params,w+dt*k3);

    w=w+dt/6.0 * (k1+2.0*k2+2.0*k3+k4);

    if (w<w_init)
      numids["PFS"]=t;

    //Sauvegarde de l'historique
    if (ctr %  200==0)
      hist_TumorMass.insert(std::pair<double, double>(t,w));


    // Incrément des compteurs
    t+=dt; ctr+=1;

  }
  numids.insert(Pair("FTV",w));

  return numids;
}

int main(int argc, char** argv) {
  Params pmap;
  pmap.insert(Pair("psi",1.0));
  pmap.insert(Pair("lambda0",1.0));
  pmap.insert(Pair("lambda1",1.0));

  const double Tmax=20.0;
  const double w_init=1.0;

  Numids numids=integrate(pmap, w_init, Tmax);
  //std::cout << "FTV : " << numids["FTV"] << std::endl;
  //std::cout << "PFS : " << numids["PFS"] << std::endl;
}
