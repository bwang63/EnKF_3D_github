[fname, pathname] = uigetfile('*.nc', 'SCRUM FILE');

fname = sprintf ( '%s%s', pathname, fname );


all_vars = ['h       ';
	    'f       ';
	    'pm      ';
	    'pn      ';
	    'dndx    ';
	    'dmde    ';
	    'x_rho   ';
	    'y_rho   ';
	    'lon_rho ';
	    'lat_rho ';
	    'x_psi   ';
	    'y_psi   ';
	    'x_u     ';
	    'y_u     ';
	    'x_v     ';
	    'y_v     ';
	    'mask_rho';
	    'mask_u  ';
	    'mask_v  ';
	    'mask_psi';
	    'angle   ' ];
	    
[r,c] = size(all_vars);
for i = 1:r
   variable = deblank ( all_vars(i,:) );

	disp ( sprintf ('testing for %s', variable ) );
	[vvar,x,y] = kslice ( fname, variable );
	a = figure ( 'Position', [10 10 600 400], ...
		     'Name', sprintf ( 'kslice %s', variable ) ); 

	if ( strcmp(variable,'h') )
	      pslice (x,y,vvar,[0 200]);
	elseif ( strcmp(variable,'mask_rho') )
	       pslice(x,y,vvar,[0 2] );
	elseif ( strcmp(variable,'mask_u') )
	       pslice(x,y,vvar,[0 1] );
	elseif ( strcmp(variable,'mask_v') )
	       pslice(x,y,vvar,[0 1] );
	elseif ( strcmp(variable,'mask_psi') )
	       pslice(x,y,vvar,[0 1] );
	else
	       minval = min(vvar(:));
	       maxval = max(vvar(:));

	       if (minval==maxval)
		   minval = minval-1;
		   maxval = maxval+1;
		end
	       pslice(x,y,vvar,[minval maxval]);
	end


	h2 = mcvgt ( fname, variable );
	b = figure ( 'position', [651   512   560   420], ...
		     'name', sprintf ( 'pcolor %s', variable ) );
	pcolor(h2);
	pause;
	delete ( a );
	delete ( b );

end

