% FATHOM: A Matlab Toolbox for Ecological & Oceanographic Data Analysis
% by Dave Jones<djones@rsmas.miami.edu>               
% http://www.rsmas.miami.edu/personal/djones
%
% f_anosim        - 1-way Analysis of Similarity (ANOSIM)
% f_anosim2       - 2-way crossed ANOSIM with no replication
% f_bartlett      - Bartlett's test for Homogeneity of Variances
% f_bioenv        - correlation of 1° distance matrix w/ all possible subsets of 2° matrix
% f_biplotEnv2    - create environmental vectors for 2-d nMDS ordination distance biplot
% f_biplotEnv3    - create environmental vectors for 3-d nMDS ordination distance biplot
% f_biplotSpecies - create species vectors for ordination distance biplot
% f_braycurtis    - calculate Bray-Curtis symmetric distance matrix
% f_brokenstick   - determine # of significant ordination dimensions via "Broken-Stick model"
% f_cap           - Canonical Analysis of Principal Coordinates using ANY distance matrix
% f_centroid      - returns coordinates of the centroid of X, optionally partitioned into groups
% f_corr          - Pearson's, Spearman's, or Kendall's correlation between 2 vectors
% f_designMatrix  - create ANOVA design matrix using dummy variables
% f_euclid        - computes Euclidean distance matrix
% f_export        - write ASCII delimited file.
% f_exportDods    - export DODS bathymetry for import into Surfer
% f_firstOccur    - returns indices of the first occurrence of unique elements of input vector
% f_gregorian     - convert Julian date to Gregorian
% f_halfchange    - scale nMDS configuration to half-change
% f_importSurfer  - import data exported from Surfer
% f_inv           - matrix inversion via "\" (left division)
% f_isDST         - determine if dates occur during Daylight Savings Time
% f_issymdis      - determine if input is square symmetric distance matrix
% f_julian        - convert date vector to Julian date
% f_labelplot     - create 2-d label plot
% f_latlong       - computes terrestrial distance matrix
% f_leapYear      - determine if a year is a leap year
% f_lenfreq       - length-frequency plot (adjusted for sampling effort)
% f_mantel        - standardized Mantel statistic for 2 symmetric distance matries
% f_modelMatrix   - create model matrix for a Mantel Test
% f_mregress      - Multiple Linear Regression via Least Squares Estimation
% f_multicomb     - generate permutation distribution of grouping labels
% f_nmds          - run Steyvers's nonmetric Multidimensional Scaling program
% f_npManova      - nonparametric (permutation-based) MANOVA for ANY distance matrix
% f_npManovaPW    - a posteriori, multiple-comparison tests
% f_pca           - Principal Component Analysis of a data matrix
% f_pcoa          - Principal Coordinates Analysis with correction for negative eigenvalues
% f_pdf           - export current figure to Acrobat PDF file
% f_permtest      - two sample permutation test of means
% f_plotUSGS      - plot USGS Coastwatch SST image with M_Map Toolbox
% f_procrustes    - Procrustes rotation of Y to X
% f_randRange     - returns n random integers ranging from min to max
% f_range         - return the min and max values of a vector
% f_ranks         - ranks data in x (with averaging of ties)
% f_readcwf       - import a Coastwatch Satellite SST file
% f_recode        - elements of vector as consecutive integers
% f_rewrap        - reverse effect of f_unwrap
% f_rgb           - utility program for selecting color of plot symbols
% f_shadeBox      - shade subsets of a time series plot
% f_shuffle       - randomly sorts vector, matrix, or symmetric distance matrix
% f_struct2flat   - a structure into a flat table & optionally export
% f_subsetDisPW   - extract subsets of distance matrix based on all pairs of grouping factor
% f_symb          - utility program for selecting plot symbols
% f_trajectory    - get distance along a trajectory
% f_transform     - transform data by 7 methods
% f_unwrap        - unwraps lower tri-diagonal (w/o diag) of symmetric distance matrix into a column vector
% f_vecAngle      - counter-clockwise angle between 2 points
% f_vecDiagram    - plot Progressive Vector Diagram
% f_vecMagDir     - get magnitude & direction from u,v vector components
% f_vecPlot       - plot time series of velocity vectors
% f_vectorfit     - plot environmental ordination vectors via multiple linear regression
% f_vecTrans      - transform 2-d vector coordinates
% f_vecTrans3d    - transform 3d vector coordinates
% f_vecUV         - returns U,V components of a vector given its magnitude & direction
% f_wascores      - weighted-averages scores of species for a site ordination
% f_windCman      - process & rotate CMAN (or NDBC) historical wind data
% f_windstress    - calculates wind stress in dynes per cm^2
% f_xdiss         - calculate Extended Dissimilarities from a symmetric distance matrix
%
%
% ----- Third party utility functions:
%
% m_2D_surf       - Draws a 2D surface on a map
% ortha           - Orthonormalization Relative to matrix A