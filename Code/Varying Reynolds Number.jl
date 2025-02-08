using Xfoil, Plots, Printf
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
alpha = 5 # range of angle of attacks, in degrees
re = collect(range(1e4, stop=1e6, length=100)) # Reynolds number

# initialize outputs
n_a = length(re)
c_l = zeros(n_a)
c_d = zeros(n_a)
c_dp = zeros(n_a)
c_m = zeros(n_a)
converged = zeros(Bool, n_a)

# determine airfoil coefficients across a range of angle of attacks
for i = 1:n_a
    c_l[i], c_d[i], c_dp[i], c_m[i], converged[i] = Xfoil.solve_alpha(alpha, re[i]; iter=500, reinit=true)
end

# print results
println("Re\t\tCl\t\tCd\t\tCm\t\tConverged")
for i = 1:n_a
    @printf("%8f\t%8f\t%8f\t%8f\t%d\n",re[i],c_l[i],c_d[i],c_m[i],converged[i])
end


# plot results
p1 = plot(re, c_l, label="", xlabel="Reynolds Number", ylabel="Cl", show=true, xscale=:log10)
p2 = plot(re, c_d, label="", xlabel="Reynolds Number", ylabel="Cd",
    overwrite_figure=false, show=true, xscale=:log10)
p3 = plot(re, c_m, label="", xlabel="Reynolds Number", ylabel="Cm",
    overwrite_figure=false, show=true, xscale=:log10)

# display each value individually
plot(p1, show=true)
plot(p2, show=true)
plot(p3, show=true)