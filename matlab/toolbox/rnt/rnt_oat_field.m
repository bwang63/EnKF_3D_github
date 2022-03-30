08-Apr-1999
15-Aug-1999
11-Oct-1999
15-Jan-2000
15-Apr-2000
06-Jul-2000

day=nc{'datenum'}(end-5:end);

dayout=[15:30:455]';
dayin=day-day(1)+1;

datain=squeeze(temp(20,8,:));

dataout=rnt_oat(dayin,datain,dayout,150);

[I J K T]= size(temp);

clear tempI err
for i=1:I 
for j=1:J
   datain=squeeze(temp(i,j,:));
   [dataout errout]=rnt_oat(dayin,datain,dayout,150);
   tempI(:,j,i)=dataout;
   err(:,j,i)=errout;
end
end   

tempI=permute(tempI,[3 2 1]);
err=permute(err,[3 2 1]);
