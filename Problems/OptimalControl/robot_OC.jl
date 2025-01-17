"""
    Robot arm problem:
        We want to find the shape of a robot arm moving between two points.
        The objective is to minimize the time taken to move between the two points.
        The problem is formulated as an OptimalControl model.
"""
function robot_OC()
# parameters
    L = 5.0
    max_u_rho = 1.0
    max_u_the = 1.0
    max_u_phi = 1.0
    max_u = [max_u_rho, max_u_the, max_u_phi]
    rho0 = 4.5
    phi0 = pi /4
    thef = 2.0 * pi / 3

    model = OptimalControl.Model(variable=true)

# dimensions
    state!(model, 6)                                  
    control!(model, 3)
    variable!(model, 1, "tf")

# time interval
    time!(model, 0, Index(1)) 
    constraint!(model, :variable, Index(1), 0.0, Inf)

# initial and final conditions
    constraint!(model, :initial, [rho0, 0.0 ,0.0, 0.0 , phi0, 0.0])       
    constraint!(model, :final,   [rho0, 0.0 , thef, 0.0 , phi0, 0.0])  

# control constraints
    constraint!(model, :control ,-max_u, max_u)

# dynamics
    dynamics!(model, (x, u, tf) -> [
        x[2],
        u[1] / L,
        x[4],
        u[2] * 3 /(((L-x[1])^3 + x[1]^3) * sin(x[5])^2),
        x[6],
        u[3] * 3 /((L-x[1])^3 + x[1]^3)
    ] )

    
# objective
    objective!(model, :mayer, (x0, xf, tf) -> tf, :min)    

    return model

end