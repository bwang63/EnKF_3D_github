

function sig = rnt_makeano(sigin,ctl);
% function sig = rnt_makeano(sigin,ctl);


for imon = 1:12
  in = find (ctl.month == imon);
  sigmean(imon)  = meanNaN(sigin(in),1);
end

for i=1:length(ctl.month)
   imon = ctl.month(i);
   sig(i) = sigin(i) - sigmean(imon);
end


