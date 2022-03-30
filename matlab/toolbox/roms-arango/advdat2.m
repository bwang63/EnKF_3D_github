function [Time,Adv]=advdat2(fname);

fid=fopen(fname,'r');
if (fid < 0),
  error(['Cannot open ' fname '.']),
end

i=0;

while feof(fid) == 0,
  [header count]=fscanf(fid,'%d %d %d %d %f %f %f',7);
  if (~isempty(header)),
    npts=header(1)+1;
    [f count]=fscanf(fid,'%d %f',[2,npts]);
    y=f(2:2:count);
    i=i+1;
    switch (i)
      case 1
        Time.a=0:1/(npts-1):1;
        Adv.a=y';
      case 2
        Time.b=0:1/(npts-1):1;
        Adv.b=y';
      case 3
        Time.c=0:1/(npts-1):1;
        Adv.c=y';
      case 4
        Time.d=0:1/(npts-1):1;
        Adv.d=y';
    end,
  end,
end,

fclose(fid);

return
