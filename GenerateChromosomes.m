%Sihao Shen
function chromosome = GenerateChromosomes( ...
    population, ... %number of design variables - elements, num_variable = 2074
    num_variable ...     %number of population at each generation
    )

%define design interval set
rel_rho_range = 0.0:0.1:0.7;

a = randi(length(rel_rho_range),num_variable,population);
random_rho = rel_rho_range(a);
chromosome = random_rho;

