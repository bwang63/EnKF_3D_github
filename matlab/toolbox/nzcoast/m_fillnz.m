function m_fillnz(fill_color)
% m_fillnz(fill_color) plots filled New Zealand outline in current 
% m_map projection 
% 
% fill_color is any valid color such as 'c' 'm' 'y' or a 3-element
% RGB vector
%
% John Wilkin - from original by Steve Chiswell

nzf = load('nzfill');

if nargin < 1
  fill_color = 0.95*[1 1 1];
end

[ix iy] = m_ll2xy(nzf.nix,nzf.niy);
[sx sy] = m_ll2xy(nzf.six,nzf.siy);
[x y] = m_ll2xy(nzf.ssx,nzf.ssy);

a = axis;
js = find(sx<a(1));  
sx(js)=[];sy(js)=[];
js = find(sx>a(2));  
sx(js)=[];sy(js)=[];

nextplt_status = get(gca,'nextplot');
set(gca,'nextplot','add')

fill(gapfill(ix),gapfill(iy),fill_color,gapfill(sx),gapfill(sy),...
    fill_color,x,y,fill_color);
    
set(gca,'nextplot',nextplt_status);

