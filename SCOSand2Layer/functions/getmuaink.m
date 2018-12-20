function [muaink] = getmuaink (wl,fname, percentsoln);

if min(wl) < 650 | max(wl) > 910
  fprintf (1,'ERROR: Wavelengths should be from 650 to 910 nm!\n');
end

% ink absorption spec from 650 to 910 nm
load([ fname ])% loads 'Aink'

wlink=Aink(:,1);

for p =1:length(wl)
    diff=wlink-wl(p);
    ind = find(abs(diff)==min(abs(diff)));
    if size(ind,1)~=1
        ind=ind(1);
    end
    Ainknew(p)=Aink(ind,2);
end

if percentsoln==1
%for 1% ink solution
muaink=log(10)*10*Ainknew;
elseif percentsoln==10
%for 10% ink solution
muaink=log(10)*100*Ainknew;
else 
  fprintf (1,'ERROR: Solution must be either 1 or 10 ink');  
end
