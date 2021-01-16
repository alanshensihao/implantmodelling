fileID = fopen('implant_remodel.bdf');    %open file

if fileID == -1         %verify if file name is correct
 error('Cannot open file')
else
C = textscan(fileID,'%s','Delimiter','\n','whitespace','');  %read data as string 
fclose(fileID);
end

%%read data
B = C{1}  ;
n = size(B,1);
w = 1;
x = 1;
y1 = 1;
y2 = 1;
z = 1;
rel_rho = 1

for i = 1:n
%find BULK DATA BEGINNING
bulkdata = strfind(B{i},'NLPARM   1       10');
if bulkdata == 1
    bulkrow = i;    %unchanged part of bdf
end

%find cylindrical coordinate system
co =strfind(B{i}, 'CORD2C  ');
if co == 1 
    coord(w) = i;
    coord(w+1) = i+1;
end
%find PSOLID
d =strfind(B{i}, 'PSOLID ');
if d == 1 
    idPSOLIDs(w) = i;
   w = w +1;
end

%find CTETRA
a =strfind(B{i}, 'CTETRA ');
if a == 1 
    idCTETRAs(x) = i;
   x = x+1;
end
%find GRID*
b1 =strfind(B{i}, 'GRID');
if b1 == 1 
    idGRIDs(y1) = i;
    idGRIDss(y2) = i+1;
   y1 = y1+1;
   y2 = y2+1;
end
%find MaterialID
c =strfind(B{i}, 'MAT1    ');
if c == 1 
    idMATERIALs(z) = i;
   z = z+1;
end
%find load and load case and contact (the end of bdf)
load = strfind(B{i},'$ Loads for Load Case ');
if load == 1
    loadrow = i;    %unchanged part of bdf
end
end


ctetra = B(idCTETRAs(1:end));
grid1 = B(idGRIDs(1:end));
grid11 = B(idGRIDss(1:end));
psolid = B(idPSOLIDs(1:end));
material = B(idMATERIALs(1:end));

%%data break down

%ctetra break down
for m3 = 1:(x-1)
    %element ID
    elementID(m3) = str2num(ctetra{m3}(9:16));
end
%convert rom to column
if size(elementID,1) ==1
elementID = elementID';
end

propertyID = elementID;

materialID = elementID;


%%
%output new text file
%save values
fid = fopen('1_implant_new_modified.bdf', 'wt');
for k = 1:bulkrow
    l = B{k};
    fprintf(fid,'%s\n',l);

end


fprintf(fid,'$$ PSOLID DATA \n$$ \n');

%change ID in psolid
x = 1;
for k = 1:size(elementID,1) %the number of elements
    
     if str2num(ctetra{k}(17:24)) == 1 %original ID  (1,2,3,4 for psolid)
         temp2 = char(psolid(1)); %CTETRA's PSOLID ID corresponds to PSOLID ID
            n = numel(num2str(k)); %count number of digits then overlap
            temp2(10:9+n) = num2str(k);    
     end
     if str2num(ctetra{k}(17:24)) == 2 
         temp2 = char(psolid(2));
            n = numel(num2str(k));
            temp2(10:9+n) = num2str(k);
     end
     if str2num(ctetra{k}(17:24)) == 3
         temp2 = char(psolid(3));
            n = numel(num2str(k));
            temp2(10:9+n) = num2str(k);
     end
     if str2num(ctetra{k}(17:24)) == 4
         temp2 = char(psolid(4));
            n = numel(num2str(k));
            temp2(10:9+n) = num2str(k);
     end
%PSOLID
x = x+1;
psolid_temp{k} = temp2; %for the use of change in material ID later

 n = numel(num2str(k));
 temp2(18:17+n) = num2str(k);
fprintf(fid,'%s \n',temp2);

end
%save psolid matrix as array
psolid_temp = psolid_temp';

fprintf(fid,'$$ CTETRA DATA \n');

x = 1;
elementID_PSOLID2 = 0;
elementID_PSOLID1 = 0;
elmeentID_PSOLID3 = 0;
elmeentID_PSOLID4 = 0;
elmeentID_PSOLID5 = 0;
e1 = 0;
e2 = 0;
e3 = 0;
e4 = 0;
e5 = 0;
%change property ID in CTETRA
for k = 1:size(elementID,1)
    temp1 = char(ctetra(k));
    if str2num(ctetra{k}(17:24)) == 1 %original ID  (1,2,3,4 for psolid)
            n = numel(num2str(k));
            temp1(18:17+n) = num2str(k);
            e1 = e1+1;
            elementID_PSOLID1(e1) = str2num(ctetra{k}(9:16));
    end
    
    if str2num(ctetra{k}(17:24)) == 2
            n = numel(num2str(k));
            temp1(18:17+n) = num2str(k);
            e2 = e2+1;
            elementID_PSOLID2(e2) = str2num(ctetra{k}(9:16));
    end
    if str2num(ctetra{k}(17:24)) == 3
            n = numel(num2str(k));
            temp1(18:17+n) = num2str(k);
            e3 = e3+1;
            elementID_PSOLID3(e3) = str2num(ctetra{k}(9:16));
    end
    if str2num(ctetra{k}(17:24)) == 4
            n =numel(num2str(k));
            temp1(18:17+n) = num2str(k);
            e4 = e4+1;
            elementID_PSOLID4(e4) = str2num(ctetra{k}(9:16));
    end
    x = x+1;
   
%CTETRA
    temp1 = string(temp1) ;
    fprintf(fid,'%s \n',temp1);
end

fprintf(fid,'$ GRID \n');

for i = 1:size(grid1,1)
    f = char(grid1(i));
    h = char(grid11(i));
    fprintf(fid,'%s\n',f);
    fprintf(fid,'%s\n',h);
end

time = datestr(now, 'HH:MM:SS');
date = date;
fprintf(fid,'$ Referenced Material Records \n');
fprintf(fid,'$ Material Record : mat1 \n');
fprintf(fid,'$ Description of Material : Date: %s           Time: %s \n',date,time);

%modify material properties

format longg
if length(material)>1 

%default is solid titanium 
E_new = str2num(material{1}(17:24))
rho_new = str2num(material{1}(41:end))
G_new = 0.35

tempmat = char(material(1));
tempmat(17:32) = "                "; 

E_new = round(E_new,3);
n = numel(num2str(E_new));

tempmat(17:16+n) = num2str(E_new,7);
if mod(E_new,1) == 0 %examine if it is not an integer
tempmat(16+n+1) = '.'
end

rho_new = round(rho_new,3);
n = numel(num2str(rho_new));
tempmat(41:40+n) = num2str(rho_new,7);
if mod(rho_new,1) == 0 %examine if it is not an integer
tempmat(40+n+1) = '.'
end
G_new = round(G_new,3);
n = numel(num2str(G_new));
tempmat(25:24+n) = num2str(G_new,7);
material(1) = cellstr(tempmat)
if mod(G_new,1) == 0 %examine if it is not an integer
tempmat(24+n+1) = '.'
end

end
%change ID in material (MAT1)
x = 1;

for k = 1:size(elementID,1)
    if str2num(psolid_temp{k}(17:24)) == 2 %original ID  (2,3,4,5 for material)
        temp3 = char(material(1)); %read material ID 2
            n = numel(num2str(k));
            temp3(10:9+n) = num2str(k); 
    end
    
    if str2num(psolid_temp{k}(17:24)) == 1 %original ID  
        temp3 = char(material(1)); %read material ID 1
            n = numel(num2str(k));
            temp3(10:9+n) = num2str(k);
    end
    
    if str2num(psolid_temp{k}(17:24)) == 3
        temp3 = char(material(2));  %read material ID 3
            n = numel(num2str(k));
            temp3(10:9+n) = num2str(k);
    end
    
    if str2num(psolid_temp{k}(17:24)) == 4
        temp3 = char(material(3)); %read material ID 4
            n = numel(num2str(k));
            temp3(10:9+n) = num2str(k);
    end
    
    if str2num(psolid_temp{k}(17:24)) == 5
        temp3 = char(material(4)); %read material ID 5
            n =numel(num2str(k));
            temp3(10:9+n) = num2str(k);
    end
    x = x+1;
   
%MAT1
    temp3 = string(temp3) ;
    fprintf(fid,'%s \n',temp3);
end
fprintf(fid,'$ SFC \n');
%load, load case
for t = loadrow:size(B,1)
    load = B{t};
    if t == size(B,1)
        fprintf(fid,'%s',load);
    else
        fprintf(fid,'%s\n',load);
    end
end
fclose(fid);