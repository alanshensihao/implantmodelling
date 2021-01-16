function RunFEAModification(generation,Population,a,new_a)
if generation == 1
    %Assign rel_rho and its properties to each element in implant in fea model
    fileID = fopen('1_implant_new_modified.bdf');    %open file
    C = textscan(fileID,'%s','Delimiter','\n','whitespace','');  %read data as string
    fclose(fileID);
    B = C{1};%read data
    length_file = length(B);%total length of the file
    
    %generate new modified fea bdf
    for i = 1:Population
        fileID1 = fopen(sprintf('implant_modified_generation_%d_%i.bdf',generation,i),'w');
        for k = 1:length_file
            %material line starts from 48972 to 48972+2073 for dental implant
            if (k >=48971 && k<= 48971+2073)
                %read that line
                %modify that line using equations from part 2
                
                %if relative density is 0, assign a small value
                if a(i,k-48970) == 0
                    rel_den = 0.001;
                else
                    rel_den = a(i,k-48970);
                end
                
                E_new = rel_den * 103400 /9 +0.001;  %lattice young's modulus
                rho_new = rel_den * 4.5; %lattice density
                v_new = 0.35;
                G_new = E_new/(2*(1+0.35))+0.001;   %lattice shear modulus. poisson ratio of titanium = 0.35
                
                tempmat = char(B{k});
                tempmat(17:45) = "                             ";
                
                E_new = round(E_new,3);
                n = numel(num2str(E_new));
                
                tempmat(17:16+n) = num2str(E_new,7);
                %         if mod(E_new,1) == 0 %examine if it is not an integer
                %             tempmat(16+n+1) = '.';
                %         end
                
                G_new = round(G_new,3);
                n = numel(num2str(G_new));
                tempmat(25:24+n) = num2str(G_new,7);
                %         if mod(G_new,1) == 0 %examine if it is not an integer
                %             tempmat(24+n:24+n+4) = '0.001';
                %         end
                
                %format poisson ratio to be the same as default 0.3 -> .3
                v_string = num2str(v_new,8);
                eliminate_zero = v_string(2:end);
                n = strlength(eliminate_zero);
                tempmat(33:32+n) = eliminate_zero;
                
                rho_new = round(rho_new,3);
                n = numel(num2str(rho_new));
                tempmat(41:40+n) = num2str(rho_new,7);
                %         if mod(rho_new,1) == 0 %examine if it is not an integer
                %             tempmat(40+n:40+n+2) = '0.0';
                %         end
                material = string(tempmat) ;
                fprintf(fileID1,'%s \n',material);
            else
                fprintf(fileID1,'%s \n',B{k});
            end
        end
        fclose(fileID1);
    end
    
else
    
    %%rewrite bdf
    %Assign rel_rho and its properties to each element in implant in fea model
    fileID = fopen('1_implant_new_modified.bdf');    %open file
    C = textscan(fileID,'%s','Delimiter','\n','whitespace','');  %read data as string
    fclose(fileID);
    B = C{1};%read data
    length_file = length(B);%total length of the file
    
    %generate new modified fea bdf
    for i = 1:Population
        fileID1 = fopen(sprintf('implant_modified_generation_%d_%i.bdf',generation,i),'w');
        for k = 1:length_file
            %material line starts from 48972 to 48972+2073 for dental implant
            if (k >=48971 && k<= 48971+2073)
                %read that line
                %modify that line using equations from part 2
                
                %if relative density is 0, assign a small value
                if new_a(i,k-48970) == 0
                    rel_den = 0.001;
                else
                    rel_den = new_a(i,k-48970);
                end
                
                E_new = rel_den * 103400 /9 +0.001;  %lattice young's modulus
                rho_new = rel_den * 4.5; %lattice density
                v_new = 0.35;
                G_new = E_new/(2*(1+0.35))+0.001;   %lattice shear modulus. poisson ratio of titanium = 0.35
                
                tempmat = char(B{k});
                tempmat(17:45) = "                             ";
                
                E_new = round(E_new,3);
                n = numel(num2str(E_new));
                
                tempmat(17:16+n) = num2str(E_new,7);
                %         if mod(E_new,1) == 0 %examine if it is not an integer
                %             tempmat(16+n+1) = '.';
                %         end
                
                G_new = round(G_new,3);
                n = numel(num2str(G_new));
                tempmat(25:24+n) = num2str(G_new,7);
                %         if mod(G_new,1) == 0 %examine if it is not an integer
                %             tempmat(24+n:24+n+4) = '0.001';
                %         end
                
                %format poisson ratio to be the same as default 0.3 -> .3
                v_string = num2str(v_new,8);
                eliminate_zero = v_string(2:end);
                n = strlength(eliminate_zero);
                tempmat(33:32+n) = eliminate_zero;
                
                rho_new = round(rho_new,3);
                n = numel(num2str(rho_new));
                tempmat(41:40+n) = num2str(rho_new,7);
                %         if mod(rho_new,1) == 0 %examine if it is not an integer
                %             tempmat(40+n:40+n+2) = '0.0';
                %         end
                material = string(tempmat) ;
                fprintf(fileID1,'%s \n',material);
            else
                fprintf(fileID1,'%s \n',B{k});
            end
        end
        fclose(fileID1);
    end
end
