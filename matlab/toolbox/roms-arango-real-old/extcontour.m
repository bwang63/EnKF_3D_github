function [CS,H]=extcontour(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11, ...
                           arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20);
%  EXTCONTOUR extended contouring package.
%        EXTCONTOUR(Z) is a contour plot of matrix Z treating the values in Z
%        as heights above a plane.
%        EXTCONTOUR(X,Y,Z), where X and Y are vectors, specifies the X- and Y-
%        axes used on the plot. X and Y can also be matrices of the same
%        size as Z, in which case they specify a surface in an identical
%        manner as SURFACE.
%        EXTCONTOUR(Z,N) and EXTCONTOUR(X,Y,Z,N) draw N contour lines, 
%        overriding the default automatic value.
%        EXTCONTOUR(Z,V) and EXTCONTOUR(X,Y,Z,V) draw LENGTH(V) contour lines 
%        at the values specified in vector V.
%     
%        Following the numeric arguments can be a number of string arguments
%        'label' to add annotation, followed by a (optional) numerical
%                argument that sets the label spacing in 'points' (default 144)
%        'fill' to do a block fill
%        e.g., EXTCONTOUR(...,'label');
%        and any number of property/value pairs where the properties are
%        text properties (beginning with 'Font...' or 'Rotation') or line 
%        properties (beginning with 'line...' or 'color'). Color and
%        linetype can also be specified as in the PLOT command.
%        e.g., EXTCONTOUR(...,'fontsize',8,'linewidth',3,'--r');
%        

% Author: Rich Pawlowicz (IOS)  rich@ios.bc.ca
%         12/12/94


% Option defaults

do_label=0;
do_fill=0;

% Parse options
numarg_for_call=['arg1'];
linarg_for_call=[];
textarg_for_call=[];

ii=2;
while (ii<=nargin),
 arg=eval(['arg' int2str(ii)]);
 if (isstr(arg)),
   xarg=[arg '       '];
   if (lower(xarg(1:3))=='lab'),
    do_label=1;
    if (ii<nargin),    % Check if label interval set
      if ~isstr(eval(['arg' int2str(ii+1)])),
        ii=ii+1;
        textarg_for_call=[textarg_for_call ',''' arg ''',arg' int2str(ii)];
      end;
    end;
   elseif (lower(xarg(1:3))=='fil'),
    do_fill=1;
   elseif (lower(xarg(1:3))=='lin' | lower(xarg(1:3))=='col'),
     ii=ii+1;
     linarg_for_call=[linarg_for_call ',''' arg ''',arg' int2str(ii) ];
   elseif (lower(xarg(1:3))=='fon' | lower(xarg(1:3))=='rot' ),
     ii=ii+1;
     textarg_for_call=[textarg_for_call ',''' arg ''',arg' int2str(ii)];
   elseif ( length(arg)<=3 ),
     colr=isletter(arg);
     if any(colr),
       linarg_for_call=[linarg_for_call ',''color'',''' arg(colr) '''' ];
     end;
     if any(~colr),
       linarg_for_call=[linarg_for_call ',''linestyle'',''' arg(~colr) '''' ];
     end;
   else
     error(['invalid argument ' eval(['arg' int2str(ii)])]);
   end;
 else  % numerical argument
   numarg_for_call = [numarg_for_call ',arg' int2str(ii) ];
 end;
 ii=ii+1;
end;

% Do the calls

% Preserve hold state at exit
holdon=ishold;

if (do_label | do_fill ),
 if do_fill,
   eval(['[CS,H]=contourfill(' numarg_for_call ');']);
   hold on;
 end;
 if do_label,
   eval(['CS=contoursurf(' numarg_for_call ');']);
   eval(['H=extclabel(CS' linarg_for_call textarg_for_call ');']);
   hold off;
 end;
else         % The standard option
 eval(['CS=contoursurf(' numarg_for_call ');']);
 k=1;
 eval(['H=plot(CS(1,k+[1:CS(2,k)]),CS(2,k+[1:CS(2,k)])' linarg_for_call ');']);
 k=k+1+CS(2,k); 
 while (k<size(CS,2)),
  eval(['H=[H;line(CS(1,k+[1:CS(2,k)]),CS(2,k+[1:CS(2,k)])' linarg_for_call ')];']);
  k=k+1+CS(2,k);
 end;
end;


if (holdon), hold on; else hold off; end;





