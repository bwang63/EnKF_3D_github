function out = domain_load(matfilesdir,domainid, loadid)
% coastline, mask, rhostretch, srho, bathymetry, grid, buffermask
loadfile = [matfilesdir '/data_domain_',loadid,'_',domainid '.mat'];
if ~exist(loadfile)
    error('    %s doesn''t exist \n',loadfile)
end
evalin('caller', sprintf('load %s', loadfile))
end