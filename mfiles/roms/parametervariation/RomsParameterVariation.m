classdef RomsParameterVariation < handle
% This class manages any number of parameters in different in-files. It is
% designed to work in conjunction with objects from the RomsInfileManager
% class but it can also be used for other tasks.
%
% the typical workflow is as follows:
% 1) once: add a number of in-files (using the function addInfile) and add
%    the parameters that are varied (using the function addParameters)
% 2) whenever needed: get samples from a certain parameter (using the
%    function sampleFrom) or transfer parameters over to in-files (using
%    the function scheduleParameterChanges)
%
% 
% LIST OF FUNCTIONS:
%
% addInfile(NAME, MAININFILELINK)
%  Add an in-file to the RomsParameterVariation object. NAME is a string
%  that is used as an ID to refer to the specific in-file. MAININFILELINK
%  is a string used to identify the in-file with objects of the
%  RomsInfileManager class and the name of a parameter in the main in-file.
% 
% addParameters(INFILENAME, PARAMETERS, DISTRIBUTIONS, ACTIVE)
%  Add one or more parameters with a distribution to an in-file.
%  INPUT:
%   INFILENAME: name of the in-file the parameter is added to
%   PARAMETERS: a single (existing) parameter name as a string or multiple
%        (existing) parameter names in a cell-string
%   DISTRIBUTION: either a cell or a vector with a distribution
%        specification for each parameter in PARAMETERS
%        
%        vector format: 
%          [distcode distparameters]
%        or  
%          {[distcode1 distparameters1],[distcode2 distparameters2],...}
%        or 
%          [distcode1 distparameters1; distcode2 distparameters2]
%        where each distcode is an integer that specifies the distribution
%        and each distparamters is a vector containing the parameters of
%        the specified distribution. 
%
%        cell format:
%          {diststring1, [distparameters1], ...}
%        where each diststring is a string that specifies the distribution
%        and each distparamters is a vector containing the parameters of
%        the specified distribution.  
% 
%        The following distributions are supported:
%    name                  distcode*         diststr  parameters
%    uniform                      1        'uniform'  a,b                (specifying the interval)
%    normal                       2         'normal'  mu, sigma          (specifying mean and standard deviation)
%    truncated normal             3    'truncnormal'  mu, sigma, a, b    (specifying mean, standard deviation an the interval)
%    log-normal                   4      'lognormal'  mu, sigma          (specifying mean and standard deviation of the underlying normal distribution)
%    negative log-normal**        5   'neglognormal'  mu, sigma          (specifying mean and standard deviation of the underlying normal distribution)
%    symmetrical truncated normal 6 'symtruncnormal'  mu, sigma, dist*** (specifying mean and standard deviation of the underlying normal distribution and the interval)
% 
%          * the integer codes are conveniently available as constant class
%            variables, i.e. 
%               rpv.uniformDistribution == 1 
%            etc. where rpv is a RomsParameterVariation object
%          ** a negative log-normal distribution is a log-normal
%            distribution with a switched sign
%          *** [mu - dist, mu + dist] is the interval
%
%    **** I found the codes for log-normal and negative log-normal are not
%    proper. I made some modifications based on function lognrnd (type help
%    lognrnd):  
%    to generate data from a lognormal distribution with mean M and
%    Variance V, use
%     MU = log(M^2 / sqrt(V+M^2));   SIGMA = sqrt(log(V/M^2 + 1))
%    R = lognrnd(MU,SIGMA,[M,N,...]) or R = lognrnd_v1(MU,SIGMA,M,N)
%    log-normal                   4      'lognormal'  M, V          (specifying mean and variance of the lognormal distribution)
%    negative log-normal**        5   'neglognormal'  M, V          (specifying mean and variance of the lognormal distribution)
%   ACTIVE (optional): a logical vector specifying which parameters are
%        active
%   Also, I used lognrnd_v1 instead of lognrnd as the latter contains some function that doesn't work in this matlab version 
%   **** /LY
%  
% activateParameters(INFILENAME, PARAMETERS, ACTIVE)
%  Activate or deactivate parameters that allready exist.  
%  INPUT:
%   INFILENAME: name of the in-file the parameter is added to
%   PARAMETERS: a single (existing) parameter name as a string or multiple
%        (existing) parameter names in a cell-string
%   ACTIVE: a logical vector specifying which parameters are activated or
%        deactivated or a single logical value (de-)activating all
%        parameters
%
% showHist(INFILENAME)
%   or 
% showHist()
%  Shows the histogram of the parameters in the in-file INFILENAME or of
%  all parameters respectively. Inactive parameters will be ignored.
%  
% samples = sampleFrom(INFILENAME, PARAMETERNAME, NUMSAMPLES)
%  Get NUMSAMPLES (optional, default: 1) samples from the parameter
%  PARAMETERNAME in the in-file INFILENAME.
%
% changes = scheduleParameterChanges(RIM, INFILENAME)
%   or 
% [change1, change2, ...] = scheduleParameterChanges(RIM, INFILENAME)
%  Transfer a sample for each parameter over to a RomsInfileManager object.
%  INPUT:
%   RIM: RomsInfileManager object 
%   INFILENAME (optional, default: all in-files) a cell-string
%        containing the names of the in-files that transfer their values.
%  Inactive parameters will be ignored. The optional output lists the
%  changes either in a cell or in separate variables.
% 
% Written by Jann Paul Mattern

    
    properties (SetAccess = protected)
        infilenames = cell(1,8);
        infiles = struct('link', {}, 'param', {}, 'dist', [], 'active', [])
        numinfiles = 0;
    end
    properties (Constant = true)
        distMatrixWidth = 5; % max number of distribution params + 1
        uniformDistribution =        1; % 2 params
        normalDistribution =         2; % 2 params
        truncNormalDistribution =    3; % 4 params
        logNormalDistribution =      4; % 2 params
        negLogNormalDistribution =   5; % 2 params
        symTruncNormalDistribution = 6; % 3 params
    end
    methods
        function this = RomsParameterVariation(option)
            if nargin > 0 && strcmpi(option, 'main')
                this.addInfile('main', 'main')
            end
        end
        function addInfile(this, name, maininfilelink)
            if ~ischar(name) || ~ischar(maininfilelink)
                error('Both input arguments must be strings.')
            elseif any(strcmpi(this.infilenames, name))
                error('In-file with name ''%s'' does already exist.', name)
            end
            this.numinfiles = this.numinfiles + 1;
            if this.numinfiles > numel(this.infilenames)
                ind = 2*numel(this.infilenames);
                this.infilenames{ind} = '';
            end
            this.infilenames{this.numinfiles} = name;
            this.infiles(this.numinfiles) = struct('link', maininfilelink, 'param', {''}, 'dist', [], 'active', []);
        end
        function addParameters(this, infilename, params, distributions, active)

            ind = find(strcmpi(this.infilenames, infilename),1);
            if ischar(params)
                params = {params};
            end
            if isempty(ind)
                error('No in-file with name ''%s'' present.', infilename)
            elseif ~iscellstr(params)
                error('Input parameters must be in a cell-string.')
            elseif numel(unique(params)) ~= numel(params)
                error('One or more parameters are specified multiple times.')
            end
            if nargin < 5
                active = true(1,numel(params));
            elseif numel(active) == 1
                if active
                    active = true(1,numel(params));
                else
                    active = false(1,numel(params));
                end
            elseif numel(active) ~= numel(params) || ~islogical(active)
                error('Input active must be a logical array with an entry for each parameter or a single logical value.')
            end

            if iscell(distributions)
                distributions = this.convert2DistMatrix(distributions);
            else
                if size(distributions, 2) < this.distMatrixWidth
                    distributions = cat(2, distributions, nan(size(distributions,1), this.distMatrixWidth-size(distributions, 2)));
                end
                status = this.checkDistMatrix(distributions);
                if status > 0
                    error('Distribution specification contains an error in row %d.', status)
                end
            end

            if isempty(this.infiles(ind).('param'))
                this.infiles(ind).('param') = params(:)';
                this.infiles(ind).('dist') = distributions;
                this.infiles(ind).('active') = active;
            else
                keepparams = true(1,numel(params));
                for k = 1:numel(params)
                    ind2 = strcmp(this.infiles(ind).param, params{k});
                    if any(ind2)
                        keepparams(k) = false;
                        this.infiles(ind).dist(ind2,:) = distributions(k,:);
                    end
                end
                if ~all(keepparams)
                    if ~any(keepparams)
                        return;
                    end
                    params = params(keepparams);
                    distributions = distributions(keepparams,:);
                end
                this.infiles(ind).param = cat(2, this.infiles(ind).param, params(:)');
                this.infiles(ind).dist = cat(1, this.infiles(ind).dist, distributions);
                this.infiles(ind).active = cat(2, this.infiles(ind).active, active);
            end
        end
        function activateParameters(this, infilename, params, active)
            ind = find(strcmpi(this.infilenames, infilename),1);
            if isempty(ind)
                error('No in-file with name ''%s'' present.', infilename)
            elseif ~iscellstr(params)
                error('Input parameters must be in a cellstring.')
            end
            if nargin < 3
                active = true(1,numel(params));
            elseif numel(active) == 1
                if active
                    active = true(1,numel(params));
                else
                    active = false(1,numel(params));
                end
            elseif numel(active) ~= numel(params) || ~islogical(params)
                error('Input active must be a logical array with an entry for each parameter or a single logical value.')
            end

            for k = 1:numel(params)
                ind2 = strcmp(this.infiles(ind).param, params{k});
                if any(ind2)
                    this.infiles(ind).active(ind2) = active(k);
                else
                    warning('RomsParameterVariation:ParameterNotFound', 'Parameter ''%s'' does not have an entry.', params{k})
                end
            end
        end
        function showHist(this, infilename)
            numsamples = 10000;

            if nargin == 1
                infileind = 1:this.numinfiles;
            else
                infileind = this.infileIndex(infilename);
            end

            numparams = sum(cat(2, this.infiles(infileind).active));

            if numparams > 100
                warning('More than 100 active parameters, only 100 will be shown.');
                numparams = 100;
            end

            n = ceil(sqrt(numparams));
            m = floor(sqrt(numparams));
            if n*m < numparams
                n = n + 1;
            end

            infilesubind = 1;
            cplotindex = 1;
            figure
            while cplotindex <= numparams
                samples = this.sampleFromDist(infileind(infilesubind), [], numsamples);
                names = this.activeParameters(infileind(infilesubind));
                for k = 1:size(samples, 1)
                    subplot(m,n,cplotindex)
                    hist(samples(k,:))
                    title(sprintf('%s (%s)', names{k}, this.infilenames{infileind(infilesubind)}));
                    cplotindex = cplotindex + 1;
                    if cplotindex > numparams
                        break
                    end
                end
                infilesubind = infilesubind + 1;
            end
        end
        function samples = sampleFrom(this, infilename, paramname, num)
            ind1 = this.infileIndex(infilename);
            ind2 = this.paramIndex(ind1, paramname);
            if nargin < 4
                num = 1;
            end
            samples = sampleFromDist(this, ind1, ind2, num);
        end
        function paramnames = activeParametersFrom(this, infilename)
            paramnames = this.activeParameters(this.infileIndex(infilename)); 
        end
        function varargout = scheduleParameterChanges(this, rim, infilename)
            if ~isa(rim, 'RomsInfileManager')
                error('First input argument must be an RomsInfileManager-object.')
            end
            if nargin < 3 || strcmp(infilename, 'all')
                infileind = 1:this.numinfiles;
            else
                infileind = this.infileIndex(infilename);
            end
            
            out = nan(100,1);
            outcounter = 0;
            for k = 1:length(infileind)
                riminfilename = rim.subInfileName(this.infiles(infileind(k)).link);
                numparams = numel(this.activeParameters(infileind(k)));
                if isempty(riminfilename)
                    warning('RomsParameterVariation:InfileNotFound', 'The in-file named ''%s'' is not linked to the RomsInfileManager-object.', this.infilenames{infileind(k)})
                    out(outcounter+1:outcounter+numparams) = nan;
                    outcounter = outcounter + numparams;
                    continue
                end
                if any(this.infiles(infileind(k)).active)
                    sample = this.sampleFromDist(infileind(k), [], 1);
                    try
                        rim.scheduleParameterChanges(riminfilename, this.activeParameters(infileind(k)), sample);
                    catch rimerror
                        warning('Scheduled parameter change for in-file ''%s'' could not be performed.\nRomsInfileManager-object threw error:\n%s', this.infilenames{infileind(k)}, rimerror.message)
                    end
                    out(outcounter+1:outcounter+numparams) = sample(:);
                    outcounter = outcounter + numparams;
                end
            end
            if nargout == 1
                varargout = {out(1:outcounter)'};
            elseif nargout > 1
                varargout = cell(1,outcounter);
                for iout = 1:outcounter
                    varargout{iout} = out(iout);
                end
            end
        end
        function disp(this)
            fprintf('RomsParameterVariation\n\n')
            for k = 1:this.numinfiles
                fprintf('    %s (link: %s)\n', this.infilenames{k}, this.infiles(k).link)
                numactive = sum(this.infiles(k).active);
                if numactive == 1
                    fprintf('        1 active parameter\n')
                else
                    fprintf('        %d active parameters\n', numactive)
                end
                fprintf('\n')
            end
        end
    end
    methods (Hidden = true)
        function samples = sampleFromDist(this, infileindex, paramindex, num)
            if isempty(paramindex)
                paramindex = find(this.infiles(infileindex).active);
            else
                if islogical(paramindex)
                    paramindex = find(paramindex);
                end
            end
            numparams = numel(paramindex);
            samples = nan(numparams, num);
            for k = 1:numparams
                cdist = this.infiles(infileindex).dist(paramindex(k),:);
                if cdist(1) == this.uniformDistribution
                    samples(k,:) = rand(1, num)*(cdist(3)-cdist(2)) + cdist(2);
                elseif cdist(1) == this.normalDistribution
                    samples(k,:) = randn(1, num)*cdist(3) + cdist(2);
                elseif cdist(1) == this.truncNormalDistribution
                    samples(k,:) = this.truncrandn(1, num, cdist(2), cdist(3), cdist(4), cdist(5));
                elseif cdist(1) == this.logNormalDistribution
                    %samples(k,:) = exp(randn(1, num)*cdist(3) +cdist(2));% written by Paul originally. 
                    %I modified it as followed: 
                    M = cdist(2);  V = cdist(3); % variance
                    MU = log(M^2 / sqrt(V+M^2));
                    SIGMA = sqrt(log(V/M^2 + 1));
                    samples(k,:) = lognrnd_v1(MU,SIGMA,1, num);
                elseif cdist(1) == this.negLogNormalDistribution
                    %samples(k,:) = -exp(randn(1, num)*cdist(3) + cdist(2));
                    M = cdist(2);  V = cdist(3); % variance
                    MU = log(M^2 / sqrt(V+M^2));
                    SIGMA = sqrt(log(V/M^2 + 1));
                    samples(k,:) = -lognrnd_v1(MU,SIGMA,1, num);
                elseif cdist(1) == this.symTruncNormalDistribution
                    samples(k,:) = this.truncrandn(1, num, cdist(2), cdist(3), cdist(2)-cdist(4), cdist(2)+cdist(4));
                end
            end
        end
        function params = activeParameters(this, infileindex)
            if numel(infileindex) == 1
                params = this.infiles(infileindex).param(this.infiles(infileindex).active);
            else
                rawparams = cell(1,numel(infileindex));
                for k = 1:numel(infileindex)
                    rawparams{k} = this.infiles(infileindex(k)).param(this.infiles(infileindex(k)).active);
                end
                params = cat(2, rawparams{:});
            end
        end
        function dmatrix = convert2DistMatrix(this, cellinput)
            if ischar(cellinput{1})
                if mod(numel(cellinput), 2) ~= 0
                    error('Invalid distribution specification.\nCell must either contain only vectors or pairs of a distribution name and a vector with distribution parameters.')
                end
                dmatrix = nan(0.5*numel(cellinput), this.distMatrixWidth);
                for k = 1:0.5*numel(cellinput)
                    distname = cellinput{2*k-1};
                    distparams = cellinput{2*k};
                    if ~isnumeric(distparams)
                        error('Parameters must be numerical. (Entry %d)', 2*k)
                    elseif strncmpi(distname, 'uniform', min(length(distname), 3))
                        dmatrix(k,1) = this.uniformDistribution;
                    elseif strncmpi(distname, 'normal', min(length(distname), 4))
                        dmatrix(k,1) = this.normalDistribution;
                    elseif strcmpi(distname, 'truncnormal') || strcmpi(distname, 'truncatednormal') || strncmpi(distname, 'tnormal', min(length(distname), 5))
                        dmatrix(k,1) = this.truncNormalDistribution;
                    elseif strcmpi(distname, 'symtruncnormal') || strcmpi(distname, 'symmetricaltruncatednormal') || strncmpi(distname, 'stnormal', min(length(distname), 6))
                        dmatrix(k,1) = this.symTruncNormalDistribution;
                    elseif strcmpi(distname, 'lognormal') || strncmpi(distname, 'lnormal', min(length(distname), 5))
                        dmatrix(k,1) = this.logNormalDistribution;
                    elseif strcmpi(distname, 'neglognormal') || strcmpi(distname, 'negativelognormal') || strncmpi(distname, 'nlnormal', min(length(distname), 6))
                        dmatrix(k,1) = this.negLogNormalDistribution;
                    elseif ischar(distname)
                        error('Unknown distribution ''%s''.', distname)
                    else
                        error('Invalid distribution specification.\nCell must either contain only vectors or pairs of a distribution name and a vector with distribution parameters.')
                    end
                    dmatrix(k,2:numel(distparams)+1) = deal(distparams);
                end
                status = this.checkDistMatrix(dmatrix);
                if status > 0
                    %error('Invalid distribution parameters. (Entry %d)', 2*status);
                end
            else
                dmatrix = nan(numel(cellinput), this.distMatrixWidth);
                for k = 1:numel(cellinput)
                    if ~isnumeric(cellinput{k})
                        error('Invalid distribution specification.\nCell must either contain only vectors or pairs of a distribution name and a vector with distribution parameters.')
                    end
                    dmatrix(k,1:numel(cellinput{k})) = deal(cellinput{k});
                end
                status = this.checkDistMatrix(dmatrix);
                if status > 0
                    error('Invalid distribution parameters. (Entry %d)', status);
                end
            end
        end
        function status = checkDistMatrix(this, dmatrix)
            status = 0; % no error
            for k = 1:size(dmatrix, 1)
                if dmatrix(k,1) == this.uniformDistribution
                    if dmatrix(k,2) < dmatrix(k,3)
                        continue
                    else
                        status = k;
                        return
                    end
                elseif dmatrix(k,1) == this.normalDistribution
                    if dmatrix(k,3) > 0
                        continue
                    else
                        status = k;
                        return
                    end
                elseif dmatrix(k,1) == this.truncNormalDistribution
                    if dmatrix(k,3) > 0 && dmatrix(k,4) < dmatrix(k,5)
                        continue
                    else
                        status = k;
                        return
                    end
                elseif dmatrix(k,1) == this.symTruncNormalDistribution
                    if dmatrix(k,3) > 0 && dmatrix(k,4) > 0
                        continue
                    else
                        status = k;
                        return
                    end
                elseif dmatrix(k,1) == this.logNormalDistribution
                    if dmatrix(k,3) > 0
                        continue
                    else
                        status = k;
                        return
                    end
                elseif dmatrix(k,1) == this.negLogNormalDistribution
                    if dmatrix(k,3) > 0
                        continue
                    else
                        status = k;
                        return
                    end
                else
                    status = k;
                    return
                end
            end
        end
        function infileind = infileIndex(this, infilename)
            if ischar(infilename)
                if strcmpi(infilename, 'all')
                    infileind = 1:this.numinfiles;
                else
                    infileind = find(strcmpi(this.infilenames, infilename),1);
                end
                if isempty(infileind)
                    error('No in-file with name ''%s'' present.', infilename)
                end
            elseif iscellstr(infilename)
                infileind = nan(1,numel(infilename));
                for k = 1:numel(infilename)
                    tmp = find(strcmpi(this.infilenames, infilename),1);
                    if isempty(tmp)
                        error('No in-file with name ''%s'' present.', infilename{k})
                    end
                    infileind(k) = tmp;
                end
            else
                error('Input must be a string or a cell-string.')
            end
        end
        function paramind = paramIndex(this, infileind, paramname)
            if ischar(paramname)
                paramind = find(strcmp(this.infiles(infileind).param, paramname),1);
                if isempty(paramind)
                    error('Parameter ''%s'' was not added to in-file ''%s''.', paramname, this.infilenames{infileind});
                end
            else
                paramind = nan(1, numel(paramname));
                for k = 1:numel(paramname)
                    tmp = find(strcmp(this.infiles(infileind).param, paramname{k}),1);
                    if isempty(tmp)
                        error('Parameter ''%s'' was not added to in-file ''%s''.', paramname{k}, this.infilenames{infileind});
                    end
                    paramind(k) = tmp;
                end
            end
        end
        function out = truncrandn(this, dim1, dim2, mu, sig, a, b)
            fab = .5*(1 + erf(([a b]-mu)./(sig*sqrt(2))));
            x = (rand(dim1, dim2)*(fab(2) - fab(1)))+fab(1);
            out = mu + sig*sqrt(2)*erfinv(2*x-1);
        end
    end
end


