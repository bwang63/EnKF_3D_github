function text = whodods(url)
%--------------------------------------------------------------------
%     Copyright (C) URI/MIT
%     Revision: 1.0
%
%  function text = whodods(URL)
%
% DESCRIPTION:
%  Get the Dataset Descriptor Structure (DDS) for a DODS data set 
%  given the URL for that data set. The DDS is an object used by DODS 
%  to encode information about a data set's variable's names and 
%  data types. `whodods' accesses the data set, requests this object
%  and writes it to standard output. 
%  
%  Because DODS can represent a wide range of data types some of the 
%  variables in a data set may not be read directly into Matlab 4.
%  The DDS can help in choosing constraints for variables so they 
%  can be interned by Matlab. See EXAMPLE for an example; See loaddods
%  for information about a Matlab 4 function which may be used to load
%  variables from DODS data sets into Matlab 4.
%  
% INPUT:
%  A DODS URL.
%
% OUTPUT:
%  A DODS Dataset descriptor structure, as text.
%
% EXAMPLE:
%  whodods('http://dodsdev.gso.uri.edu/cgi-bin/nph-nc/data/coads.nc')
%	-> Returns structured text describing the names and types
%	   of variables in the dataset `coads.nc' in directory 'data'
%	   on `dods.gso.uri.edu'.
%
%  whodods('http://dods.gso.uri.edu/cgi-bin/nph-nc/data/fnoc1.nc')
%       -> Returns:
%	Dataset {
%	    Int32 u[time_a = 16][lat = 17][lon = 21];
%	    Int32 v[time_a = 16][lat = 17][lon = 21];
%	    Float64 lat[lat = 17];
%	    Float64 lon[lon = 21];
%	    Float64 time[time = 16];
%	} fnoc1;
%
%	Indicating that the data set contains five arrays: U and V
%	have three dimensions while LAT, LON and TIME have one. Note
%	that because Matlab 4 is limited to vectors and matrices, U
%	and/or V must be constrained to two dimensions before they can 
%	be read. See loaddods for more information.
%  
% CALLER: general purpose
% CALLEE: whodods.m
%
% AUTHOR: James Gallagher, URI
%---------------------------------------------------------------------

eval(['!./writedap -D -- ', url])


