%% main function - minimization
clc,clear,close all

%%%%%%%%%%%%%%%%%%%
%%Global Constant%%
Num_Variable = 2074;
Population = 4;
Generation = 100;
Chromosome_Length = Num_Variable*3;
Crossover_Probability = 0.8;
Mutation_Probability = 0.15;  %mutation is for gene, but our gene is too long
%Mutation_Percentage_Coverage = 0.2  %20 mutation in each chromosome
Bi_Length = 3;
w_0 = 0.5; %objective function weight on each term
w_1 = 0.5;
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%local data initialization%%
%%%%%%Memory Allocation%%%%%
dec_before = zeros(Population,Num_Variable);
dec_after  = zeros(Population,Num_Variable);
dna = zeros(Population,Num_Variable*Bi_Length);
dna_reproduced = dna;
fitness_chance = zeros(Generation,Population);
fitness_score_sum = zeros(Generation,Population);
interface_failure_sum = zeros(Generation,Population);
bone_loss_sum = zeros(Generation,Population);
selection = zeros(Population,1);
rotation = zeros(Population,1);
roulette_interval = zeros(Population,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
path = addpath('src','data','feamodel','batch');
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%I N I T I A L  R A N D O M   C H R O M O S O M E S%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generation = 1;
GetChromosome = @GenerateChromosomes;
a = GetChromosome(Population, Num_Variable);
a = reshape(a,Population,[]); %a is by row
initial_a = a;
new_a = zeros(Population, Num_Variable);

%modify fea bdf
ReadFEAModification = @RunFEAModification;
ReadFEAModification(generation, Population, a, new_a);

%%
%%%%%%%%%%%%%%%%%
%%%E N C O D E%%%
%%%%%%%%%%%%%%%%%
for i = 1:Population
    %encode -> dec to binary
    %change to integer first by multiplying 10
    dec_before(i,:) = floor(10 * a(i,:));
    
    %correct the format reading from the left as the most significant
    for k = 1:3:Chromosome_Length
        dna(i,k:k+2) = de2bi(dec_before(i,(k+2)/3),3,'left-msb');
    end
    
    initial_dna = dna;
    %%
    %obtarin results for each initial population
    ReadNastran = @RunNastran;
    ReadNastran(generation,Population)
    
    
    %%
    %read results for each initial population to prepare for fitness function
    ReadNastranResults = @RunNastranResults;
    ReadNastranResults(generation,Population)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%F I T N E S S  F U N C T I O N%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ReadFitness = @RunFitness;
    [fitness_score,interface_failure_index,bone_loss_percentage] = ReadFitness(generation,Population,w_0,w_1);
    fitness_sum = sum(fitness_score);
    for ii = 1:Population
        fitness_chance(1,ii) = fitness_score(ii) / fitness_sum;
        fitness_score_sum(1,ii) = fitness_score(ii);
        interface_failure_sum(1,ii) = interface_failure_index(ii);
        bone_loss_sum(1,ii) = bone_loss_percentage(ii);
    end
    
    
    %end of initial generation
end

for generation = 2 : Generation+1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%S E L E C T I O N  O F  P A R E N T S%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %selection methods
    %roullete wheel selection
    for num_rotation = 1:Population
        for i = 1:Population
            roulette_interval(i) = sum(fitness_chance(generation-1,1:i));
        end
        rotation(num_rotation) = rand;  %determing a random value
        for ii = 1:Population
            if ii == 1
                if rotation(num_rotation) <= roulette_interval(ii)
                    selection(num_rotation) = ii;
                end
            else
                if rotation(num_rotation)> roulette_interval(ii-1) && rotation(num_rotation) <= roulette_interval(ii)
                    selection(num_rotation) = ii;
                    break;
                end
            end
        end
        dna_reproduced(num_rotation,:) = dna(selection(num_rotation),:);
    end
    dna = dna_reproduced;
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%C R O S S O V E R  A N D  M U T A T I O N%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ReadCrossover= @RunCrossover;
    new_dna = ReadCrossover(Num_Variable, Population, Chromosome_Length, Crossover_Probability, Mutation_Probability, dna);
    
    
    %%
    %%%%%%%%%%%%%%%%%
    %%%D E C O D E%%%
    %%%%%%%%%%%%%%%%%
    for i = 1:Population
        %decode -> binary to dec
        %correct the format reading from the left as the most significant
        for k = 1:3:Chromosome_Length
            dec_after(i,(k+2)/3) = bi2de(new_dna(i,k:k+2),'left-msb');
        end
    end
    %change back to relative density by dividing 10
    new_a = dec_after/10;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%F I T N E S S  F U N C T I O N%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ReadFitness = @RunFitness;
    [fitness_score,interface_failure_index,bone_loss_percentage] = ReadFitness(generation-1,Population,w_0,w_1);
    fitness_sum = sum(fitness_score);
    for i = 1:Population
        fitness_chance(generation-1,i) = fitness_score(i) / fitness_sum;
        fitness_score_sum(generation-1,i) = fitness_score(i);
        interface_failure_sum(generation-1,i) = interface_failure_index(i);
        bone_loss_sum(generation-1,i) = bone_loss_percentage(i);
    end
    
    
    for i = 1:Population
        %encode -> dec to binary
        %change to integer first by multiplying 10
        dec_before(i,:) = floor(10 * new_a(i,:));
        
        %correct the format reading from the left as the most significant
        for k = 1:3:Chromosome_Length
            dna(i,k:k+2) = de2bi(dec_before(i,(k+2)/3),3,'left-msb');
        end
        
    end
    
    %modify fea bdf
    ReadFEAModification = @RunFEAModification;
    ReadFEAModification(generation, Population, a, new_a);
    
    %%
    %obtarin results for each initial population
    ReadNastran = @RunNastran;
    ReadNastran(generation,Population)
    
    %%
    %read results for each initial population to prepare for fitness function
    ReadNastranResults = @RunNastranResults;
    ReadNastranResults(generation,Population)
    
end





