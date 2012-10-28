#encoding: utf-8
# Module d'intégration temporel
module TimeIntegrator
    # Intégration par Euler explicite
    #
    # @param [NArray] y_tn Vecteur au temps précédent
    # @param [FixNum] dt Pas de temps
    # @return [NArray] vecteur au temps (n+1)dt
    def ts_euler_explicit(y_tn, dt)
        y_tn+dt*func(y_tn)
    end

    # Intégration par Runge-Kutta d'ordre 2
    #
    # @param [NArray] y_tn Vecteur au temps précédent
    # @param [FixNum] dt Pas de temps
    # @return [NArray] vecteur au temps (n+1)dt
    def ts_RK2(y_tn,dt)
        y_dem=y_tn+0.5*dt*func(y_tn)
        y_tn+dt*func(y_dem)
    end

    # Intégration par Runge-Kutta d'ordre 4
    #
    # @param [NArray] y_tn Vecteur au temps précédent
    # @param [FixNum] dt Pas de temps
    # @return [NArray] vecteur au temps (n+1)dt
    def ts_RK4(y_tn, dt)
        k1=func(y_tn)
        k2=func(y_tn+0.5*dt*k1)
        k3=func(y_tn+0.5*dt*k2)
        k4=func(y_tn+dt*k3)

        y_tn+dt/6.0 * (k1+2.0*k2+2.0*k3+k4)
    end
end

