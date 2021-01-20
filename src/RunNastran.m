function RunNastran(Generation,Population)
%number of population at each generation
for i = 1 : Population
    Format = ('C:\MSC.Software\MSC_Nastran\20180\bin\nastran.exe "F:\Implant\Optimization\implant_GA\implant_modified_generation_%d_%i.bdf" scr=yes batch=no delete=h5,xdb,f04,log');
    P = char(Format);
    p = strfind(P,'%d');
    PA = P(1:p-1);
    
    PB = sprintf('%d_',Generation);
    PC = sprintf('%d',i);
    PD = P(p+5:end);
    PC = string(PC);
    PA = string(PA);
    PD = string(PD);
    PB = string(PB);
    P_new =strcat(PA,PB,PC,PD)
    
    fileopen = fopen('F:\Implant\Optimization\implant_GA\nas101b.bat','w');
    fprintf(fileopen,'%s',P_new);
    fclose(fileopen);
    %run nastran analysis
    system("F:\Implant\Optimization\implant_GA\nas101b.bat")
end




