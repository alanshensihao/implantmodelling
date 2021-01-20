Population = 4
generation = 1

dna = [1 2 3 4;2 3 4 5;3 4 5 5; 1 3 4 7]

ReadFitness = @RunFitness;
fitness_score = ReadFitness(generation,Population);
fitness_sum = sum(fitness_score);
for i = 1:Population
    fitness_chance(i) = fitness_score(i) / fitness_sum
end
    
for num_rotation = 1:Population
    rotation = rand;
for i = 1:Population
    if i ~= 1
       if rotation <= sum(fitness_chance(1:i)) && rotation >= sum(fitness_chance(1:i-1))
           selection(num_rotation) = i;
       end
    else
       if rotation <= fitness_chance(i)
           selection(num_rotation) = i;
       end
    end
end
    dna_new(num_rotation,:) = dna(selection(num_rotation),:);
end
