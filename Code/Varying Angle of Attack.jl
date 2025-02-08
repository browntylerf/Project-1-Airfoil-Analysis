using Xfoil, Plots, Printf
pyplot

# read airfoil coordinates from a file
x, y = open("naca2412.dat", "r") do f
    x = Float64[]
    y = Float64[]
    for line in eachline(f)
        entries = split(chomp(line))
        push!(x, parse(Float64, entries[1]))
        push!(y, parse(Float64, entries[2]))
    end
    x, y
end

# load airfoil coordinates into XFOIL
Xfoil.set_coordinates(x,y)
xr, yr = Xfoil.pane()

# plot the airfoil geometry
scatter(xr, yr, label="", framestyle=:none, aspect_ratio=1.0, show=true)

# set operating conditions
alpha = -10:.5:14 # range of angle of attacks, in degrees
re = 1e5 # Reynolds number
mach = 0 # Mach number

# initialize outputs
n_a = length(alpha)
c_l = zeros(n_a)
c_d = zeros(n_a)
c_dp = zeros(n_a)
c_m = zeros(n_a)
converged = zeros(Bool, n_a)

# determine airfoil coefficients across a range of angle of attacks
for i = 1:n_a
    c_l[i], c_d[i], c_dp[i], c_m[i], converged[i] = Xfoil.solve_alpha(alpha[i], re; mach, iter=500, reinit=true)
end

# print results
println("Angle\t\tCl\t\tCd\t\tCm\t\tConverged")
for i = 1:n_a
    @printf("%8f\t%8f\t%8f\t%8f\t%d\n",alpha[i],c_l[i],c_d[i],c_m[i],converged[i])
end


# plot results
plot()

# Plot each coefficient on separate y-axes (stacked layout)
p1 = plot(alpha, c_l, label= false, xlabel="Angle of Attack (degrees)", ylabel="Cl", 
           grid=true)

p2 = plot(alpha, c_d, label=false, xlabel="Angle of Attack (degrees)", ylabel="Cd", 
          grid=true)

p3 = plot(alpha, c_m, label=false, xlabel="Angle of Attack (degrees)", ylabel="Cm", 
          grid=true)

# display each plot individually
plot(p1, show=true)
plot(p2, show=true)
plot(p3, show=true)