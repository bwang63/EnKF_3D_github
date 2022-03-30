function fillnz(fill_color) 
% fillnz(fill_color) plots filled New Zealand outline in current axes
%
% fill_color is any valid color such as 'c' 'm' 'y' or a 3-element
% RGB vector
%
% John Wilkin - from original by Steve Chiswell

nzf = load('nzfill');

if nargin < 1
  fill_color = 0.95*[1 1 1];
end

nextplt_status = get(gca,'nextplot');
set(gca,'nextplot','add')

% fill(nzf.nix,nzf.niy,fill_color,nzf.six,nzf.siy,fill_color,...
%    nzf.ssx,nzf.ssy,fill_color);

fill3(nzf.nix,nzf.niy,ones(size(nzf.nix)),fill_color,...
    nzf.six,nzf.siy,ones(size(nzf.six)),fill_color,...
    nzf.ssx,nzf.ssy,ones(size(nzf.ssx)),fill_color);

set(gca,'nextplot',nextplt_status);

