function result = f_nmds(dist,ndims,initial,plotflag,maxiter,conv,rotate);
% - run Steyvers's nonmetric Multidimensional Scaling program
%
% Usage: config = f_nmds(dist,{ndims},{initial},{plotflag},{maxiter},{conv},{rotate});
%
% -----Input:-----
% dist     = symmetric dissimilarity matrix
% ndims    = number of dimensions of solution (default = 2)
% initial  = initial config: 1 = Torgeson-Young scaling (default); 0 = random;
% plotflag = plot results (default = 1);
% maxiter  = max. iterations (default = 50)
% conv     = convergence criterion (default = 0.001)
% rotate   = rotate final configuration to Principal Coordinates (default = 1)
%
% -----Output:-----
% config.mds    = configuration of solution in (ndims) dimensions
% config.stress = final stress of solution
% config.dim    = # of dimensions of solution
% config.rsq    = Mantel statistic comparing fitted distance with original dissimilarities
%
% SEE ALSO: f_pca, f_pcoa

% -----Dependencies:-----
% Mark Steyver's Nonmetric Multidimensional Scaling Toolbox:
% http://www-psych.stanford.edu/~msteyver/programs_data/mdszip.zip
% TMW's Optimization toolbox

% -----References & Changes:-----
% modified after Steyvers' domds.m by Dave Jones, April-2001
% made variable random seed, added rotate to PCA, Mantel Statistic,
% and formatting of output (July-2001)

% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

%-----Check input and set default values:-----

if (nargin < 2) ndims    = 2;      end;
if (nargin < 3) initial  = 1;      end;
if (nargin < 4) plotflag = 1;      end;
if (nargin < 5) maxiter  = 50;     end;
if (nargin < 6) conv     = 0.0001; end;
if (nargin < 7) rotate   = 1;      end;

% -----Check input:-----
if (f_issymdis(dist) == 0)
   error('Input DIST must be square symmetric distance matrix');
end;

%
no         = size(dist,1);  % size of input dissimilarity matrix
plotdim1   = 1;     % which dimension on x-axis
plotdim2   = 2;     % which dimension on y-axis
R          = 2.0;   % R values in Minkowski metric
seed     	 = sum(100*clock); % seed for random number generator [%% modified by DJ]
minoption  = 1;  	% 1 = minimize stress1    2 = minimize stress2
%---------------------------------------------

% provide some text labels for the stimulus points here
for i=1:no
   labels{ i } = sprintf( '%d' , i );
end

userinput{2} = R;
userinput{3} = ndims;
userinput{4} = maxiter;
userinput{5} = conv;
userinput{6} = 1;         % 0=no 1=yes, printed comments
userinput{7} = 0;
userinput{8} = 0;
userinput{9} = initial;
userinput{10}= 0;
userinput{11}= seed;
userinput{13}= 0;         % 0=do not symmetrize input matrix % 1=do symmetrize
userinput{14}= 0;
userinput{15}= minoption;

% ---------------------------------------------------------------------------------
%    CALL THE MDS ROUTINE
[ Config,DHS,DS,DeltaS,Stress1,StressT1,Stress2,StressT2,Rs,RsT] = ...
   nmds(userinput,dist);
% ---------------------------------------------------------------------------------

% -----Rotate final configuration to Principal Coordinates:-----% [DJ]
if (rotate>0), Config = f_pca(Config,0); end;

% -----Mantel Statistic comparing distances to dissimilarities:-----% [DJ]
mantelRsq = (f_mantel(dist,f_euclid(Config'),1))^2; % rank-correlation

% -----Format output as a structure-----% [DJ]
result.mds    = Config;
result.stress = Stress1;
result.dim    = ndims;
result.rsq    = (mantelRsq * 100);



if plotflag==1 %% plot results if true
   % ---------------------------------------------------------------------------------
   %                            Create the Shepard Plot
   % ---------------------------------------------------------------------------------
   figure; %% open NEW figure window (DLJ)
   plot( DS , DeltaS , 'ro' , DHS , DeltaS , '-b.' );
   grid on;
   axis square;
   axis tight;
   ylabel( 'dissimilarities' );
   xlabel( 'distances' );
   title( sprintf( 'stress1=%1.4f stress2=%1.4f Rs=%1.4f (N=%d)' , Stress1 , Stress2 , Rs , no ) , 'FontSize' , 8 );
   
   % ---------------------------------------------------------------------------------
   %                            Create the plot with stimulus coordinates
   % ---------------------------------------------------------------------------------
   figure; %% open NEW figure window (DLJ)
   if (ndims==1)
      plot( Config(:,1) , Config(:,1) , 'r.' );
      grid on;
      axis square;
      xlabel( 'dimension 1' );
      ylabel( 'dimension 1' );
      
      for i=1:no
         text( Config(i,1)+0.1 , Config(i,1) , labels{i},'FontSize' , 8); %% added fontsize (DLJ)
      end;   
   elseif (ndims>=2)
      plot( Config(:,plotdim1) , Config(:,plotdim2) , 'r.' );
      grid on;
      axis square;
      xlabel( sprintf( 'dimension %d' , plotdim1 ));
      ylabel( sprintf( 'dimension %d' , plotdim2 ));
      
      for i=1:no
         text( Config(i,plotdim1)+0.1 , Config(i,plotdim2) , labels{i} );
      end;   
   end;
   axis equal;   
end;

