using Xfoil, Plots, Printf, DifferentialEquations
pyplot

# read airfoil coordinates from a file
x, y = open("naca2424.dat", "r") do f
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
alpha = -13:1:15 # range of angle of attacks, in degrees
re = 1e5 # Reynolds number

# initialize outputs
n_a = length(alpha)
c_l = zeros(n_a)
c_d = zeros(n_a)
c_dp = zeros(n_a)
c_m = zeros(n_a)
c_l_over_c_d = zeros(n_a)
converged = zeros(Bool, n_a)

# determine airfoil coefficients across a range of angle of attacks
for i = 1:n_a
    c_l[i], c_d[i], c_dp[i], c_m[i], converged[i] = Xfoil.solve_alpha(alpha[i], re; iter=100, reinit=true)
    c_l_over_c_d[i] = c_l[i] / c_d[i]
end

# print results
println("Angle\t\tCl\t\tCd\t\tCm\t\tConverged")
for i = 1:n_a
    @printf("%8f\t%8f\t%8f\t%8f\t%d\n",alpha[i],c_l[i],c_d[i],c_m[i],converged[i])
end


# plot results
plot(alpha, c_l_over_c_d, label="", xlabel="Angle of Attack (degrees)", ylabel="Lift-to-Drag Ratio (L/D", show=true)
savefig("my_plot.png")