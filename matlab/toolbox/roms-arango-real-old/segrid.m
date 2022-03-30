function [zpt, nodeglob, nelem, npts, iglob] = segrid
%
% Read a spectral element grid file
% usage is [zpt, nodeglob, nelem, npts iglob] = grid
%
% zpt		contains the x-y coordinate pairs of the grid
% nodeglob	is the total number of nodes in the grid
% nelem		is the total number of elements in the grid
% npts		is the number of points per element
% iglob		is the connectivity of the grid.
%

%       printf("Enter file name of first block: ");
%       fscanf(stdin, "%s", string);

% get the name of the file
  filename = input('Enter file name:','s');

  fp = fopen(filename, 'r');
  if fp==-1
    printf('unable to open file %s, quitting...\n', filename);
    exit(1);
  end

% Read the number of nodes and elements from stdin
  npar = fscanf(fp, '%d', 9);
% npar = fscanf(fp, '%d', 3);
  nodeglob = npar(1);
  nelem = npar(2);
  npts = npar(3);
  node = npts*npts;
  fprintf('nodeglob=%d\n', nodeglob);
  fprintf('nelem=%d\n', nelem);
  fprintf('npts=%d\n', npts);

%read the node coordinates
  zpt = fscanf(fp,'%lf', [2 nodeglob]);

  iglob = fscanf(fp,'%d', [node nelem]);

  fclose(fp);
