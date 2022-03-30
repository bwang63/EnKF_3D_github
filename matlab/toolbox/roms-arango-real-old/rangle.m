%theta=rangle(ulon,ulat,vlon,vlat);

deg2rad=pi/180;
[Lm,M]=size(ulon);
L=Lm+1;
Lm2=L-2;
Mm=M-1;
Mm2=M-2;

dlatu=ulat(2:Lm,1:Mm)-ulat(1:Lm2,1:Mm);
dlonu=(ulon(2:Lm,1:Mm)-ulon(1:Lm2,1:Mm)).* ...
      cos(0.5.*(ulat(1:Lm2,1:Mm)+ulat(2:Lm,1:Mm)).*deg2rad);
alpha=atan2(-dlatu,-dlonu);

dlatv=vlat(1:Lm,1:Mm2)-vlat(1:Lm,2:Mm);
dlonv=(vlon(1:Lm,1:Mm2)-vlon(1:Lm,2:Mm)).* ...
      cos(0.5.*(vlat(1:Lm,1:Mm2)+vlat(1:Lm,2:Mm)).*deg2rad);
beta=atan2(dlonv,-dlatv);

