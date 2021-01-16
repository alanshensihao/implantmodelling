function new_dna = RunCrossover(Num_Variable,Population, Chromosome_Length,Crossover_Probability,Mutation_Probability, dna)
% single point crossover
fprintf("crossover begins\n")
new_dna = zeros(Population,Chromosome_Length);
end_chromosome = Population - 1;
for i = 1:2:(end_chromosome)
    if rand < Crossover_Probability
        d = i+1;                        % define the population to crossover with
        m = dna(d,:);                                 % extract chromosome
        cross_point= randi(Num_Variable);             % crossover point
        cross_point_binary = cross_point * 3;
        new_dna(i,:) = [dna(i,1:cross_point_binary), m(cross_point_binary+1:end)]; % new chromosome 1 from each population
        new_dna(i+1,:) = [m(1:cross_point_binary), dna(i,cross_point_binary+1:end)];  % new chromosome 2 from each population
    else
        new_dna(i,:) = dna(i,:);
        new_dna(i+1,:) = dna(i+1,:);
    end
end

fprintf("mutation begins\n")
tic
for i = 1:Population                        % mutation for every single gene
    for k = 1:Chromosome_Length
        if rand < Mutation_Probability
            new_dna(i,k) = randi([0, 1]);
        end
    end
end
toc
