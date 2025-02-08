using Xfoil, Plots

# Read airfoil coordinates from a file
function read_airfoil(file)
    x, y = Float64[], Float64[]
    open(file, "r") do f
        for line in eachline(f)
            entries = split(chomp(line))
            push!(x, parse(Float64, entries[1]))
            push!(y, parse(Float64, entries[2]))
        end
    end
    return x, y
end

# Initialize files to be evaluated
airfoil_files = ["naca0008.dat", "naca2424.dat", "naca2408.dat", "naca0024.dat"]

# Set operating conditions
alpha = -7:.5:10 # Range of angle of attacks, in degrees
re = 1e5 # Reynolds number
n_a = length(alpha)

# Initialize plot
plot1 = plot(label="", xlabel="Angle of Attack (degrees)", ylabel="Lift Coefficient", show=false, legend=:bottomright)

# Load airfoil coordinates into XFOIL
for file in airfoil_files
    x, y = read_airfoil(file)
    Xfoil.set_coordinates(x, y)

    c_l = zeros(n_a)
    c_d = zeros(n_a)
    c_dp = zeros(n_a)
    c_m = zeros(n_a)
    converged = zeros(Bool, n_a)

    # Determine airfoil coefficients across a range of angle of attacks, append to plot
    for i = 1:n_a
        c_l[i], c_d[i], c_dp[i], c_m[i], converged[i] = Xfoil.solve_alpha(alpha[i], re; iter=5000, reinit=true)
    end
    print(c_l)
    new_label = replace(file, ".dat" =>"")
    plot!(plot1, alpha, c_l, label=new_label)
end

# Display results
display(plot1)
