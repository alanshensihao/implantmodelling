function [score_out,interface_failure_index,bone_loss_percentage] = RunFitness(Generation,Population,w_0,w_1)   %number of population at each generation)
%define fitness criteria and variables
%the best should have the lowest value
%we should also consider failure criteria
%we have objective functions - interface failure and bone loss
%we want to minimize both simultaneously
%we need to first of all normalize our terms

%global constant
%from ReadToothInterface
Read_Solid_Interface_Failure_Index = @ReadSolidImplantInterface;
Solid_Interface_Failure_Index = Read_Solid_Interface_Failure_Index();
F = zeros(1,Population);

%local constant
cort_rho = 2.17;
can_rho = 1;
f1 = zeros(129,1);
f2 = zeros(401,1);
norm_x1 = zeros(129,1);
shear_xy1 = zeros(129,1);
norm_x2 = zeros(401,1);
shear_xy2 = zeros(401,1);
objective_function1 = zeros(Population,1);


%%
%read interface failure and bone loss data
fprintf('define fitness function value and objective funtions begin \n')

fid = fopen('can ESD-tooth-alan.txt','rt');
Can_ESD = textscan(fid, '%f%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
fclose(fid);
Can_ESD_Matrix = cell2mat(Can_ESD);

fid = fopen('cort ESD-tooth-alan.txt','rt');
Cort_ESD = textscan(fid, '%f%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
fclose(fid);
Cort_ESD_Matrix = cell2mat(Cort_ESD);



for num_analysis = 1:Population
    %objective function 1
    Normal_Stress_Matrix = zeros(530,2);
    Shear_Stress_Matrix = zeros(530,2);
    
    fid = fopen(sprintf('normalstress_x_%d_%i.txt',Generation,num_analysis),'r');
    Normal_Stress = textscan(fid, '%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ');
    fclose(fid);
    Normal_Stress_Matrix = cell2mat(Normal_Stress);
    
    if num_analysis == 1
        aaaa1 = Normal_Stress_Matrix;
    end
    if num_analysis == 2
        aaaa2 = Normal_Stress_Matrix;
    end
    fid = fopen(sprintf('shearstress_xy_%d_%i.txt',Generation,num_analysis),'r');
    Shear_Stress = textscan(fid, '%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ');
    fclose(fid);
    Shear_Stress_Matrix = cell2mat(Shear_Stress);
    
    %part 1 cortical
    St_cort = 14.5*(cort_rho^1.71);
    Sc_cort = 32.4*(cort_rho^1.85);
    Ss_cort = 21.6*(cort_rho^1.65);
    for k = 1:length(Normal_Stress_Matrix)
        for i = 1:length(Cort_ESD_Matrix)
            if Normal_Stress_Matrix(k,1) == Cort_ESD_Matrix(i,1)
                element(i) = Normal_Stress_Matrix(k);
                norm_x1(i) = Normal_Stress_Matrix(k,2);
                shear_xy1(i) = Shear_Stress_Matrix(k,2);
                f1(i) = 1/(St_cort*Sc_cort)*(norm_x1(i)^2) + (1/St_cort - 1/Sc_cort)*abs(norm_x1(i))+1/(Ss_cort^2)*(shear_xy1(i)^2);
            end
        end
    end
    
    %part 2 cancellous
    St_can = 14.5*(can_rho^1.71);
    Sc_can = 32.4*(can_rho^1.85);
    Ss_can = 21.6*(can_rho^1.65);
    for ii = 1:length(Can_ESD_Matrix)
        for kk = 1:length(Normal_Stress_Matrix)
            if Normal_Stress_Matrix(kk,1) == Can_ESD_Matrix(ii,1)
                norm_x2(ii) = Normal_Stress_Matrix(kk,2);
                shear_xy2(ii) = Shear_Stress_Matrix(kk,2);
                f2(ii) = 1/(St_can*Sc_can)*(norm_x2(ii)^2) + (1/St_can - 1/Sc_can)*abs(norm_x2(ii))+1/(Ss_can^2)*(shear_xy2(ii)^2);
            end
        end
    end
    
    sum(f1);
    sum(f2);
    objective_function1(num_analysis) = sum(f1)+sum(f2);
    %%
    %objective function 2 - bone loss
    %Element Strain Density (ESD)
    %to be continued for bone loss after dental implant is able to run properly
    %in nastran to get ESD results.
    
    
    fid = fopen(sprintf('ESD_%d_%i.txt',Generation,num_analysis),'rt');
    ESD = textscan(fid, '%f%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
    fclose(fid);
    ESD_Matrix = cell2mat(ESD);
    
    %cortical part
    
    
    n = 0; %count total #of ESD
    for iii = 1:length(ESD_Matrix)
        for kkk = 1:length(Cort_ESD_Matrix)
            if ESD_Matrix(iii,1) == Cort_ESD_Matrix(kkk,1)
                n = n+1;
                if ESD_Matrix(iii,2) < Cort_ESD_Matrix(kkk,2)*0.5
                    test(n) = 1;
                else
                    test(n) = 0;
                end
            end
        end
    end
    
    %cancellous part
    for i = 1:length(ESD_Matrix)
        for k = 1:length(Can_ESD_Matrix)
            if ESD_Matrix(i,1) == Can_ESD_Matrix(k,1)
                n = n+1;
                if ESD_Matrix(i,2) < Can_ESD_Matrix(k,2)*0.5
                    test(n) = 1;
                else
                    test(n) = 0;
                end
            end
        end
    end
    
    if size(test,1) ==1
        test = test'; %column to row
    end
    failure = 0;
    for i = 1:n
        if test(i) == 1
            failure = failure + 1;
        end
    end
    
    objective_function2(num_analysis) = failure/n;
    
end
%%

interface_failure_index = reshape(objective_function1,[],1); %reshape
bone_loss_percentage = reshape(objective_function2,[],1); %reshape


fid = fopen(sprintf('results_%0.1f.txt',num_analysis),'wt');
for ii = 1:size(interface_failure_index,1)
    fprintf(fid,'%g\t            %g',interface_failure_index(ii),bone_loss_percentage(ii));
    fprintf(fid,'\n');
end
fclose(fid);

for num = 1:Population
    %normalization
    normalized_interface_failure(num) = interface_failure_index(num)/Solid_Interface_Failure_Index;
    
    %reverse, we want to minimize, therefore, we are looking for greater values now
    F(num) = 1/(bone_loss_percentage(num) * w_0 + normalized_interface_failure(num) * w_1);
    fprintf("fitness value is %f1.4 \n",F(num));
end

score_out = F;
fprintf('fitness function end \n')





