%%read tooth interface failure data
function solid_implant_interface_index = ReadSolidImplantInterface()
%local constant
cort_rho = 2.17;
can_rho = 1;
f1 = zeros(129,1);
f2 = zeros(401,1);
norm_x1 = zeros(129,1);
shear_xy1 = zeros(129,1);
norm_x2 = zeros(401,1);
shear_xy2 = zeros(401,1);
Normal_Stress_Matrix = zeros(530,2);
Shear_Stress_Matrix = zeros(530,2);

%cancellous bone result with original tooth
fid = fopen('can ESD-element.txt','rt');
Can_ESD = textscan(fid, '%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
fclose(fid);
Can_ESD_Matrix = cell2mat(Can_ESD);

%cortical bone result with original tooth
fid = fopen('cort ESD-element.txt','rt');
Cort_ESD = textscan(fid, '%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
fclose(fid);
Cort_ESD_Matrix = cell2mat(Cort_ESD);


if isfile('solid_implant_normalstress_x_1.txt')
    %no calculation
else
    
    tic
    fid = fopen('1_implant_solid_implant_modified.f06','r');
    if fid == -1         %verify if file name is correct
        error('Cannot open file')
    else
        C = textscan(fid,'%s','Delimiter','\n','whitespace',''); %read as string
        fclose(fid);
    end
    
    %search stress results
    B = C{1};
    k = 0;
    e = 0;
    f = 0;
    stress_begin = 99999999;
    count = 0;
    
    for ii = 237116:length(B)
        
        a = strfind(B{ii},'                   S T R E S S E S   I N    T E T R A H E D R O N   S O L I D   E L E M E N T S   ( C T E T R A )');
        if a == 1
            k = k+1;
            if k == 1
                stress_begin = ii; %find the beginning line of stress output
            end
        end
        c = B{ii};
        if ii >= stress_begin && length(c)> 43
            d = c(17:end);
            if (d(1:8) == ' CENTER ')
                e = e + 1;
                for o = ii-9:ii-1  %find elementID
                    ele = 0;
                    ele = strfind(B{o},'1GRID CS  4 GP'); %might change to 0GRID depending on coordinate system ID used
                    if ele == 23
                        elementID(e) = str2num(B{o}(2:20));
                    end
                end
                
                normal_xstress = d(13:27);  %center normal stress x
                a1 = str2num(normal_xstress);
                normalstress_x(e) = a1;
                shear_xystress = d(32:47);  %center shaer stress xy
                a2 = str2num(shear_xystress);
                shearstress_xy(e) = a2;
            end
        end
        
        ESD_begin = strfind(B{ii},'                                           E L E M E N T   S T R A I N   E N E R G I E S');
        if ESD_begin == 1
            f = f+1;   % fth times of ESE page
        end
        if f == 1
            g = ii;   %where ESD data begins
        end
        ESD_end = strfind(B{ii},' * * * *  D B D I C T   P R I N T  * * * * ');
        if ESD_end == 1
            h = ii;
        end
    end
    
    
    
    for n = 640000:length(B) %ESD begin g, end h
        y = B{n};
        if length(y) > 40
            if length(y)>=50
                if str2num(y(40:50)) >= 1
                    count = count+1;
                    ESE_ID = str2num(y(40:50));
                    value = str2num(y(100:end));
                    ESD(count) = value;
                    element_ESD(count) = ESE_ID;
                end
            end
        end
    end
    
    
    %row to column
    if size(normalstress_x,1) ==1
        normalstress_x = normalstress_x';
    end
    
    if size(shearstress_xy,1) ==1
        shearstress_xy = shearstress_xy';
    end
    
    if size(ESD,1) ==1
        ESD = ESD';
    end
    
    if size(element_ESD,1) ==1
        element_ESD = element_ESD';
    end
    
    ESD_matrix = [element_ESD,ESD];
    
    %% output stress data
    %mkdir(sprintf('analysis_%i_results',num_analysis)) %create result folder
    
    fileopen = fopen('solid_implant_normalstress_x_1.txt','w');
    
    
    for lll = 1:401
        for l = 1:length(elementID)
            if Can_ESD_Matrix(lll,1) == elementID(l)
                str1 = "        ";
                str2 = "        ";
                
                temp1 = char(str1);
                if numel(num2str(abs(elementID(l)),8)) == 1;   %determine length of ID and output it
                    temp1(1) = mat2str(elementID(l));
                else
                    n = numel(num2str(abs(elementID(l))));
                    temp1(1:n)= mat2str(elementID(l));
                end
                
                temp2 = char(str2);
                if numel(num2str(normalstress_x(l),8)) == 1;   %determine length of value and output it
                    temp2(l) = mat2str(normalstress_x(l));
                else
                    if  normalstress_x(l) < 0
                        n = numel(num2str(normalstress_x(l)));
                        a = num2str(normalstress_x(l));
                        temp2(1:n)= a;
                    else
                        n = numel(num2str(normalstress_x(l)));
                        a = num2str(normalstress_x(l));
                        temp2(2:n+1)= a;
                    end
                end
                
                str1 = string(temp1);
                str2 = string(temp2);
                
                s = strcat(str1,str2);
                fprintf(fileopen,'%s \n',s);
            end
        end
    end
    
    for lll = 1:129
        for l = 1:length(elementID)
            nnnnn = 1;
            if Cort_ESD_Matrix(lll,1) == elementID(l)
                str1 = "        ";
                str2 = "        ";
                
                temp1 = char(str1);
                if numel(num2str(abs(elementID(l)),8)) == 1;   %determine length of ID and output it
                    temp1(1) = mat2str(elementID(l));
                else
                    n = numel(num2str(abs(elementID(l))));
                    temp1(1:n)= mat2str(elementID(l));
                end
                
                temp2 = char(str2);
                if numel(num2str(normalstress_x(l),8)) == 1;   %determine length of value and output it
                    temp2(l) = mat2str(normalstress_x(l));
                else
                    if  normalstress_x(l) < 0
                        n = numel(num2str(normalstress_x(l)));
                        a = num2str(normalstress_x(l));
                        temp2(1:n)= a;
                    else
                        n = numel(num2str(normalstress_x(l)));
                        a = num2str(normalstress_x(l));
                        temp2(2:n+1)= a;
                    end
                end
                
                str1 = string(temp1);
                str2 = string(temp2);
                
                s = strcat(str1,str2);
                fprintf(fileopen,'%s \n',s);
            end
        end
    end
    fclose(fileopen);
    
    %%
    %output shear stress data
    fileopen = fopen('solid_implant_shearstress_xy_1.txt','w');
    
    
    for lll = 1:401
        for l = 1:length(elementID)
            if Can_ESD_Matrix(lll,1) == elementID(l)
                str1 = "        ";
                str2 = "        ";
                
                temp1 = char(str1);
                if numel(num2str(abs(elementID(l)),8)) == 1
                    temp1(1) = mat2str(elementID(l));
                else
                    n = numel(num2str(abs(elementID(l))));
                    temp1(1:n)= mat2str(elementID(l));
                end
                
                temp2 = char(str2);
                
                if numel(num2str(shearstress_xy(l),8)) == 1
                    temp2(l) = mat2str(shearstress_xy(l));
                else
                    if  shearstress_xy(l) < 0
                        n = numel(num2str(shearstress_xy(l)));
                        a = num2str(shearstress_xy(l));
                        temp2(1:n)= a;
                    else
                        n = numel(num2str(shearstress_xy(l)));
                        a = num2str(shearstress_xy(l));
                        temp2(2:n+1)= a;
                    end
                end
                
                str1 = string(temp1);
                str2 = string(temp2);
                
                s = strcat(str1,str2);
                fprintf(fileopen,'%s \n',s);
            end
        end
    end
    
    for lll = 1:129
        for l = 1:length(elementID)
            if Cort_ESD_Matrix(lll,1) == elementID(l)
                str1 = "        ";
                str2 = "        ";
                
                temp1 = char(str1);
                if numel(num2str(abs(elementID(l)),8)) == 1
                    temp1(1) = mat2str(elementID(l));
                else
                    n = numel(num2str(abs(elementID(l))));
                    temp1(1:n)= mat2str(elementID(l));
                end
                
                temp2 = char(str2);
                
                if numel(num2str(shearstress_xy(l),8)) == 1
                    temp2(l) = mat2str(shearstress_xy(l));
                else
                    if  shearstress_xy(l) < 0
                        n = numel(num2str(shearstress_xy(l)));
                        a = num2str(shearstress_xy(l));
                        temp2(1:n)= a;
                    else
                        n = numel(num2str(shearstress_xy(l)));
                        a = num2str(shearstress_xy(l));
                        temp2(2:n+1)= a;
                    end
                end
                
                str1 = string(temp1);
                str2 = string(temp2);
                
                s = strcat(str1,str2);
                fprintf(fileopen,'%s \n',s);
            end
        end
    end
    toc
end

%calculate interface failure index
fid = fopen('solid_implant_normalstress_x_1.txt','r');
Normal_Stress = textscan(fid, '%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ');
fclose(fid);
Normal_Stress_Matrix = cell2mat(Normal_Stress);

fid = fopen('solid_implant_shearstress_xy_1.txt','r');
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
solid_implant_interface_index = sum(f1)+sum(f2);