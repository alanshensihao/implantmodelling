%%run nastran
    Format = ('C:\MSC.Software\MSC_Nastran\20180\bin\nastran.exe "F:\Implant\Optimization\implant_GA\1_implant_tooth_modified.bdf" scr=yes batch=no delete=h5,xdb,f04,log');
    P = char(Format);
    P_new =P;
    fileopen = fopen('F:\Implant\Optimization\implant_GA\nas101b.bat','w');
    fprintf(fileopen,'%s',P_new);
    fclose(fileopen);
    %run nastran analysis
    system("F:\Implant\Optimization\implant_GA\nas101b.bat")

%% read data
fid = fopen('can ESD-element.txt','rt');
Can_ESD = textscan(fid, '%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
fclose(fid);
Can_ESD_Matrix = cell2mat(Can_ESD);

fid = fopen('cort ESD-element.txt','rt');
Cort_ESD = textscan(fid, '%f', 'MultipleDelimsAsOne',true, 'Delimiter','[;');
fclose(fid);
Cort_ESD_Matrix = cell2mat(Cort_ESD);

for i = 1
    
    fid = fopen('1_implant_tooth_modified.f06','r');
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
     
    for i = 273778:664453
        
        a = strfind(B{i},'                   S T R E S S E S   I N    T E T R A H E D R O N   S O L I D   E L E M E N T S   ( C T E T R A )');
       if a == 1
            k = k+1;
            if k == 1
                stress_begin = i; %find the beginning line of stress output
            end
       end
       c = B{i};
       if i >= stress_begin && length(c)> 43
            d = c(17:end);
            if (d(1:8) == ' CENTER ')
                e = e + 1;
                for o = i-9:i-1  %find elementID
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
       
       ESD_begin = strfind(B{i},'                                           E L E M E N T   S T R A I N   E N E R G I E S');
       if ESD_begin == 1
           f = f+1;   % fth times of ESE page
       end
       if f == 1
           g = i;   %where ESD data begins
       end
       ESD_end = strfind(B{i},' * * * *  D B D I C T   P R I N T  * * * * ');
       if ESD_end == 1
           h = i;
       end
    end
     

     
    for n = 658410:683054 %ESD begin g, end h
        y = B{n};
        if length(y) > 40
            if str2num(y(40:50)) >= 1
                count = count+1;
                ESE_ID = str2num(y(40:50));
                value = str2num(y(100:end));
                ESD(count) = value;
                element_ESD(count) = ESE_ID;
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


nnn = 0;
kk = 1;
    %% output ESD data
    fileopen = fopen('cort ESD-tooth-alan','w');
    for lll = 1:129
        for l = 1:20232
            if Cort_ESD_Matrix(lll,1) == element_ESD(l)
                nnn = 1;
                str1 = "        ";
                str2 = "        ";

                temp1 = char(str1);
                if numel(num2str(abs(element_ESD(l)),8)) == 1;  %smiliar to output stress data
                    temp1(1) = mat2str(element_ESD(l));
                else   
                    n = numel(num2str(abs(element_ESD(l))));
                    temp1(1:n)= mat2str(element_ESD(l));
                end
        
                temp2 = char(str2);
        
                if numel(num2str(ESD(l),8)) == 1;
                    temp2(l) = mat2str(ESD(l));
                else   
                    if  ESD(l) < 0     
                        n = numel(num2str(ESD(l)));
                        a = num2str(ESD(l));
                        temp2(1:n)= a;
                    else 
                        n = numel(num2str(ESD(l)));
                        a = num2str(ESD(l));
                        temp2(2:n+1)= a;
                    end
                end
    
                str1 = string(temp1);
                str2 = string(temp2);
    
                s = strcat(str1,str2);
                
            end
           
        end
        if nnn == 0
            uncountElement(kk) = Cort_ESD_Matrix(lll,1);
                str1 = "        ";
                str2 = " 0       ";

                temp1 = char(str1);
                if numel(num2str(abs(Cort_ESD_Matrix(lll,1)),8)) == 1;  %smiliar to output stress data
                    temp1(1) = mat2str(Cort_ESD_Matrix(lll,1));
                else   
                    n = numel(num2str(abs(Cort_ESD_Matrix(lll,1))));
                    temp1(1:n)= mat2str(Cort_ESD_Matrix(lll,1));
                end
                str1 = string(temp1);

    
                s = strcat(str1,str2);
        kk = kk + 1;
        end
        nnn = 0;
        fprintf(fileopen,'%s \n',s);
    end
    fclose(fileopen);

    fileopen = fopen('can ESD-tooth-alan','w');
 kkk = 1;
 nnnn = 0;
    for lll = 1:401
        for l = 1:20232
            if Can_ESD_Matrix(lll,1) == element_ESD(l)
                nnnn = 1;
                str1 = "        ";
                str2 = "        ";

                temp1 = char(str1);
                if numel(num2str(abs(element_ESD(l)),8)) == 1;  %smiliar to output stress data
                    temp1(1) = mat2str(element_ESD(l));
                else   
                    n = numel(num2str(abs(element_ESD(l))));
                    temp1(1:n)= mat2str(element_ESD(l));
                end
        
                temp2 = char(str2);
        
                if numel(num2str(ESD(l),8)) == 1;
                    temp2(l) = mat2str(ESD(l));
                else   
                    if  ESD(l) < 0     
                        n = numel(num2str(ESD(l)));
                        a = num2str(ESD(l));
                        temp2(1:n)= a;
                    else 
                        n = numel(num2str(ESD(l)));
                        a = num2str(ESD(l));
                        temp2(2:n+1)= a;
                    end
                end
    
                str1 = string(temp1);
                str2 = string(temp2);
    
                s = strcat(str1,str2);
                fprintf(fileopen,'%s \n',s);
            end
        end
                if nnnn == 0
            uncountElement1(kkk) = Can_ESD_Matrix(lll,1);
                str1 = "        ";
                str2 = " 0       ";

                temp1 = char(str1);
                if numel(num2str(abs(Can_ESD_Matrix(lll,1)),8)) == 1;  %smiliar to output stress data
                    temp1(1) = mat2str(Can_ESD_Matrix(lll,1));
                else   
                    n = numel(num2str(abs(Can_ESD_Matrix(lll,1))));
                    temp1(1:n)= mat2str(Can_ESD_Matrix(lll,1));
                end
                str1 = string(temp1);

    
                s = strcat(str1,str2);
        kkk = kkk + 1;
        end
        nnnn = 0;
    end
    fclose(fileopen);


end
 