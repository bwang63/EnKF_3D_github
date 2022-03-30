
load brsdat2;

ms=[];
mcs=[];
msindx=[];
mcsindx=[];


for i=1:size(master_archives,1)
   eval(sprintf( ...
  '[ms,mcs,msindx,mcsindx]=makemasterurl(i,''%s'',ms,mcs,msindx,mcsindx);', ...
        deblank(master_archives(i,:)) ));
end

ms=ms(2:size(ms,1),:);
mcs=mcs(2:size(mcs,1),:);

