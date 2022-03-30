
function pac_coast(varargin)

if nargin == 0
   color='k'
else
   color = varargin{1};
end

pc=load('/d1/manu/foreman/data/PacificCoast.dat');
plot(pc(:,1),pc(:,2),color)
