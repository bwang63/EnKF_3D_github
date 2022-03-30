function path_name = pos_cds() 

% POS_CDS returns the path to the common data set directory.
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, april 15 1992
%     Revision $Revision: 1.2 $
%
% DESCRIPTION:
% pos_cds returns the path to the common data set directory.
% This is the directory containing netcdf files accessible to all
% users.
% 
% INPUT:
% none
%
% OUTPUT:
% path_name: the path to the common data set directory.
%
% EXAMPLE:
% Simply type path_name at the matlab prompt.
%
% CALLER:   check_nc.m, getcdf.m, getcdf_b.m, inqcdf.m, whatcdf.m
% CALLEE:   None
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.2 $
%     Author   $Author: mansbrid $
%     Date     $Date: 2000/05/01 07:23:08 $
%     RCSfile  $RCSfile: pos_cds.m,v $
% @(#)pos_cds.m   1.1   92/04/16
% 
%--------------------------------------------------------------------

%path_name = [ ];
path_name = [ '/home/netcdf-data/' ];
