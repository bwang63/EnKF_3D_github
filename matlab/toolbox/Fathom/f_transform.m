function tdata = f_transform(data,method);
% - transform data by 7 methods
%
% Usage: tdata = f_transform(data,method);
%
% data   = RxC matrix; Rows = abiotic variables or species, Cols = sites
% method = type of transformation
% tdata  = transformed data
%
% ----- Methods: -----
% Biotic data  = 1: Square Root
%                2: Fourth Root
%                3: Log10(x+1)
%                4: Natural Log(x+1)
%                5: Log2(x+1)
%                6: Species Standardization
%
% Abiotic data = 7: Normalize by row
%                8: Sum-of-Squares = 1 by row
%          
% ----- Ecological Applications: -----
%"Transform" your BIOTIC raw data before calculating a dissimilarity matrix
% to give more weight to rarer species. Relative effect: squart root < fourth root < log.
%
%"Standardize" abundances by species (row-wise) in your BIOTIC raw data instead of "transforming"
% when using in a SPECIES ordination or cluster analysis.
%
%"Normalize" your ABIOTIC data row-wise (by variable) AFTER making any transformations.
% For each value of a variable (row), the mean is subtracted and divided by the standard
% deviation so the variance of each variable = 1. This makes all variables equally
% weighted & is especially useful for abiotic variables that are measured on different
% scales or in different units. 

% by Dave Jones <djones@rsmas.miami.edu>, April-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% 03-Apr-2002: fixed 'divide by zero' error in normalize
% 18-Apr-2002: improved error message

if (nargin < 2) method = 999; end;

switch method
case 1
   tdata = data.^(1/2);
   %fprintf('Data squart-root transformed. \n');
case 2
   tdata = data.^(1/4);
   %fprintf('Data fourth-root transformed. \n');
case 3
   tdata = log10(data + 1);
   %fprintf('Data Log-transformed. \n');
case 4
   tdata = log(data + 1);
   %fprintf('Data Ln(x+1) transformed. \n');
case 5
   tdata = log2(data + 1);
   %fprintf('Data Log2(x+1) transformed. \n');
case 6
   noRows = size(data,1); % number of rows
   for i = 1:noRows
      thisRow   = data(i,:);  % extract all columns of this row
      rowTotal  = sum(thisRow);
      tdata(i,:) = (thisRow ./ rowTotal) * 100; % divide each value by total abundance
   end
   %fprintf('Species abundances have been stardardized by row. \n');
case 7
   noRows = size(data,1); % number of rows
   for i = 1:noRows
      thisRow   = data(i,:); % extract all columns of this row
      if (std(thisRow) == 0) % prevent 'divide by zero' errors
         tdata(i,:) = (thisRow .* 0);
      else
         tdata(i,:) = (thisRow - mean(thisRow))/std(thisRow); % subtract mean & divide by stdev
      end
   end
   %fprintf('Data have been normalized by row. \n');   
case 8   
   noRows = size(data,1); % number of rows 
   for i=1:noRows % normalize so sum-of-squares = 1
      tdata(i,:) = data(i,:)./(sqrt(sum(data(i,:).^2))); 
   end;
   %fprintf('Data have been normalized by row so Sum-of-Squares = 1. \n');   
otherwise  
   error('Unknown transformation unknown!');
end

