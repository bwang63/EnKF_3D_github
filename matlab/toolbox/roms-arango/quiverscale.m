function quiverscale(px,py,H)
        %QUIVERSCALE creates a scale at the bottom of the quiver plot, 
        %which plots the longest vector of the data set(px,py) and displays 
        %the vector's corresponding magnitude. The H input argument is the 
        %handle to the quiver plot axes.
        %
        %Please note that the QUIVERSCALE function returns 
        %accurate results only when the vectors are plotted 
        %to actual scale (e.g.  QUIVER(U,V,S), where S=0).
        %
        %Vincent Hodges 02/03/98

        h=get(H,'position');
        h2=h;
        h1=h(2)/4;
        h(2)=h(2)+h1;
        h(4)=h(4)-h1;
        set(gca,'position',h);
        hlim=get(gca,'xlim');
        h2(end)=h2(end)/20;
        h2(2)=h2(2)/3;
        ax=axes('position',h2);
        hlim(1)=0;
        set(ax,'xlim',hlim);
        xsq=px.^2;
        ysq=py.^2;
        arrowmag=max(unique(sqrt([xsq+ysq])));
        size1=prod(size(arrowmag));
        arrowmag2=reshape(arrowmag,size1,1);
        X=zeros(size1,1);
        Y=1:size1;
        null=zeros(size1,1);
        quiver(X,Y,arrowmag2,null,0);
        set(ax,'xlim',hlim);
        set(ax,'ytick',[]);

return
