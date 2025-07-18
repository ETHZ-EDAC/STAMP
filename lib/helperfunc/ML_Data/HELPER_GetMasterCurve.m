% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function varargout = HELPER_GetMasterCurve(varargin)

%% Input Checks
switch nargin
    case 2 % material matrix is given
        mat = varargin{1};
        matinfo = varargin{2};
        Tg_raw = [20,80];
    case 3 % target properties are given
        MatTarget = varargin{1};
        Tg_raw    = varargin{2};
        mode      = varargin{3};
    otherwise %no valid input
        error('Wrong number of input arguments')
end


%% Initialize Networks
%  navigate to folder
cd lib
cd helperfunc
cd ML_Data

% python environment
global pyenvdef
try
    pyenv('Version', pyenvdef);
catch
    error(['Python environment at path "',pyenvdef,'" could not be set up.']);
end

% network names
name_estimRho = 'NNestR_W180D7LR0001BS256AF0E150';
name_estimE   = 'NNestE_W150D7LR00001BS256AF0E150';
% network architecture
depth_estimRho = 7;
width_estimRho = 180;
af_estimRho    = 0;
depth_estimE   = 7;
width_estimE   = 150;
af_estimE      = 0;

% variable ranges
rhorange = [0,1];
Trange   = [-30,130];
frange   = [-15,15];
Erange   = [0.3,2096.07];

% percolation threshold
rhocrit = 0.163;

% initialize global variables
global NNmodule; global netRho; global netE;
% load module
NNmodule = py.importlib.reload(py.importlib.import_module('NNrun'));
% load networks
netRho = NNmodule.getModel(['NNtrained',filesep,name_estimRho,'.pth'],3,1,depth_estimRho,width_estimRho,af_estimRho);
netE   = NNmodule.getModel(['NNtrained',filesep,name_estimE,'.pth'],3,1,depth_estimE,width_estimE,af_estimE);

%% Pre-Process
switch nargin
    % change support voxels to void
    case 2
        % find support material
        fnames = fieldnames(matinfo);
        fnames(end-3:end) = [];
        suppID = [];
        for matno = 1:size(fnames,1)
            if isfield(matinfo.(fnames{matno,1}),'isSupp')
                if matinfo.(fnames{matno,1}).isSupp == 1
                    suppID = [suppID,matinfo.(fnames{matno,1}).ID];
                end
            end
            if strcmp(fnames{matno,1},'void')
                voidID = matinfo.(fnames{matno,1}).ID;
            end
        end

        % material matrix support columns
        suppCol = matinfo.mat2col(ismember(matinfo.mat2col(:,1),suppID),2)';
        % void column
        voidCol = matinfo.mat2col(ismember(matinfo.mat2col(:,1),voidID),2)';
        % mat rows with pure support
        rowSupp = find(mat(:,suppCol)==10000);
        % replace support with void
        mat(rowSupp,suppCol) = 0;
        mat(rowSupp,voidCol) = 10000;
end

%% Estimate Mixtures
switch nargin
    case 2
        % get material names
        mnames = fnames;
        for iname = 1:length(mnames)
            mnames{iname} = matinfo.(fnames{iname}).Name;
        end
        % get ID of AB and VW
        IDAB = nan; IDVW = nan;
        for iname = 1:length(mnames)
            if strcmp(mnames{iname},'Agilus')
                IDAB = iname;
            elseif strcmp(mnames{iname},'VeroWhiteUltra')
                IDVW = iname;
            elseif strcmp(mnames{iname},'Void')
                IDVO = iname;
            end
        end
        if isnan(IDAB+IDVW)
            error('Not both Agilus and VeroWhiteUltra defined.')
        end

        % check if  material mixtures consist of only AB and WV
        ismat = logical(sign(sum(mat,1)));
        isactive = find(ismat==1);
        if ~isempty(setdiff(isactive,[IDAB,IDVW,IDVO]))
            error('Other material then Agilus and VeroWhiteUltra used')
        end

        % unique AB/VW material mixtures
        [mixes,~,uniqueMixID] = unique(mat,'rows');

        %  excpetion: make void mix to ID 0
        rowDel = find(mixes(:,1)==10000);
        if ~isempty(rowDel)
            mixes(rowDel,:) = [];
            uniqueMixID  =  changem(uniqueMixID,0,rowDel);
        end
        
        % read unique rho values
        rho =  double(mixes(:,IDAB))/10000;

        % get Tg values
        for i = 1:size(rho,1)
            if (1-rho(i,1)) < rhocrit
                Tg_mix(i,1) = Tg_raw(1);
            else
                Tg_mix(i,1) = (diff(Tg_raw)*((1-rho(i,1))-rhocrit)^0.5187)/((1-rhocrit)^0.5187)+Tg_raw(1);
            end
        end

    case 3
        % target pairs
        targetPairs = [repelem([1:1:size(MatTarget,1)],size(MatTarget,1))',repmat([1:1:size(MatTarget,1)]',size(MatTarget,1),1)];
        targetPairs(diff(targetPairs,1,2)==0,:) = [];
        targetPairs = unique(sort(targetPairs,2),'rows');
        % expand targets
        discr = 10;
        MatTargetExpand = zeros(discr*size(targetPairs,1),3);
        for i = 1:size(targetPairs,1)
            MatTargetExpand((i-1)*10+1:i*10,1) = linspace(MatTarget(targetPairs(i,1),1),MatTarget(targetPairs(i,2),1),discr);
            MatTargetExpand((i-1)*10+1:i*10,2) = 10.^linspace(log10(MatTarget(targetPairs(i,1),2)),log10(MatTarget(targetPairs(i,2),2)),discr);
            MatTargetExpand((i-1)*10+1:i*10,3) = linspace(MatTarget(targetPairs(i,1),3),MatTarget(targetPairs(i,2),3),discr);
        end
        MatTargetExpand = unique(MatTargetExpand,"rows");
        if isempty(MatTargetExpand)
            MatTargetExpand = MatTarget;
        end
        % run network
        rhoExpand = estimRho(MatTargetExpand,rhorange,Trange,frange,Erange,rhocrit);
        % put rho into range
        rhoExpand(rhoExpand<0)=0;
        rhoExpand(rhoExpand>1)=1;
        % average rho
        rho = mean(rhoExpand);
        % estimate Tg of mixture
        if (1-rho) < rhocrit
            Tg_mix = Tg_raw(1);
        else
            Tg_mix = (diff(Tg_raw)*((1-rho)-rhocrit)^0.5547)/((1-rhocrit)^0.5547)+Tg_raw(1);
        end
end


%% Estimate Master Curve
switch nargin
    case 2
        % fitting temperature
        Tfit = repmat(22,size(Tg_mix));
        % frequency input
        fin = 10.^linspace(frange(1),frange(2),1000)';        
        % assemble input
        in = [reshape(repelem(rho,1000),[],1),  ...
              reshape(repelem(Tfit,1000),[],1), ...
              repmat(fin,size(rho,1),1)];
        % run network
        MasterCurve = estimE(in,rhorange,Trange,frange,Erange);
        % reshape
        MasterCurve =  reshape(MasterCurve,1000,[]);
    case 3
        % switch depending on input mode
        switch mode
            % evaluate curve at Tg
            case 'Tg'
                % frequency input
                fin = 10.^linspace(frange(1),frange(2),1000)';
                % assemble input
                in = [rho*ones(1000,1),Tg_mix*ones(1000,1),fin];
                % run network
                MasterCurve = estimE(in,rhorange,Trange,frange,Erange);
        
            % evaluate curve at all T
            case 'full'
                % frequency input
                fin = 10.^linspace(frange(1),frange(2),1000)';
                % assemble input
                in = [rho*ones(1000*(diff(Trange)+1),1),repelem(linspace(Trange(1),Trange(2),diff(Trange)+1),1000)',repmat(fin,(diff(Trange)+1),1)];
                % run network
                MasterCurve = estimE(in,rhorange,Trange,frange,Erange);
                % reshape
                MasterCurve = reshape(MasterCurve,1000,[]);
        end
        
        %% Calculate Mismatch
        % assemble input
        in = [rho*ones(size(MatTarget,1),1),MatTarget(:,1),MatTarget(:,2)];
        % run network
        EatTarget = estimE(in,rhorange,Trange,frange,Erange);
        % difference to target
        Mismatch = EatTarget - MatTarget(:,3);
end

%% Finish
% assemble outputs
switch nargin
    case 2
        varargout{1} = MasterCurve';
        varargout{2} = uniqueMixID;
        varargout{3} = Tg_mix;
        varargout{4} = rho;
    case 3
        varargout{1} = MasterCurve;
        varargout{2} = rho;
        varargout{3} = Tg_mix;
        varargout{4} = Mismatch;
end
% navigate back
cd ..
cd ..
cd ..

end

%% Estimates Rho
function rho = estimRho(input,rhorange,Trange,frange,Erange,rhocrit)
    % adjust rho range
    rhorange(2) = rhorange(2) - rhocrit;
    % global variables
    global NNmodule
    global netRho
    % normalize input
    input(:,2) = log10(input(:,2));
    input      = input - repmat([Trange(1),frange(1),Erange(1)],size(input,1),1);
    input      = input ./ repmat([diff(Trange),diff(frange),diff(Erange)],size(input,1),1);
    % calculate output
    rho = double(NNmodule.runBatch(netRho,py.numpy.array(input)));
    % de-normalize
    rho = rho * diff(rhorange) + rhorange(1);
end

%% Estimates E
function E = estimE(input,rhorange,Trange,frange,Erange)
    % global variables
    global NNmodule
    global netE
    % normalize input
    input(:,3) = log10(input(:,3));
    input      = input - repmat([rhorange(1),Trange(1),frange(1)],size(input,1),1);
    input      = input ./ repmat([diff(rhorange),diff(Trange),diff(frange)],size(input,1),1);
    % calculate output
    Enorm = double(NNmodule.runBatch(netE,py.numpy.array(input)));
    % scale output
    E =  Enorm * range(Erange) + Erange(1);
end