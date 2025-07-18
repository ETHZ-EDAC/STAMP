% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function [gridinfo,mat,matinfo,stlfile] = PREPROCESS_voxelstructure(name,cg_res,matinfo,rotation,type,savemode,elemsize)
    %% Load STL file
    % progress report
    fprintf('Read STL file ... ');

    % load files if allready created
    if strcmp(savemode,'load')
        % get load name
        delimiterpos = strfind(name,filesep);
        if isempty(delimiterpos)
            fname  = name;
            folder = '';
        else
            fname  = name(delimiterpos(end)+1:end);
            folder = name(1:delimiterpos(end));
        end
        fname = fname(1:end-4);
        lname = [folder,'SAVE_',fname,'.mat'];

        % load saved file
        savestruct = load(lname).savestruct;

        % load data from strct
        gridinfo = savestruct.gridinfo;
        mat      = savestruct.mat;
        matinfo  = savestruct.matinfo;
        stlfile  = savestruct.stlfile;

    % create files for savemodes 'save' and 'none'
    elseif strcmp(savemode,'save') | strcmp(savemode,'none')

    % load stl file
    switch type
        case 'solid'
            stlfile = READ_stl(name); % read with custom function
        case 'shell'
            stlfile = stlread(name); % read with default matlab function
            faces   = stlfile.ConnectivityList; % faces
            verts   = stlfile.Points; % vertices
            stlfile = PREPROCESS_SampleShellSTL(stlfile,elemsize); % convert
    end
        
    %% Rotate STL file
    % build rotation matrix
    phi = rotation / 180 * pi;
    rotmat_x = [1,0,0;0,cos(phi(1)),-sin(phi(1));0,sin(phi(1)),cos(phi(1))];
    rotmat_y = [cos(phi(2)),0,sin(phi(2));0,1,0;-sin(phi(2)),0,cos(phi(2))];
    rotmat_z = [cos(phi(3)),-sin(phi(3)),0;sin(phi(3)),cos(phi(3)),0;0,0,1];
    rotall = rotmat_z * rotmat_y * rotmat_x;

    % rotate STL file
    switch type
        case 'solid'
            % rotate
            stlfile(:,:,1) = (rotall * stlfile(:,:,1)')';
            stlfile(:,:,2) = (rotall * stlfile(:,:,2)')';
            stlfile(:,:,3) = (rotall * stlfile(:,:,3)')';        
            % rearrange structure (Nx3 array with xyz coordinates for each unique node)
            stlnodes = unique([stlfile(:,:,1); stlfile(:,:,2); stlfile(:,:,3)],'rows');
        case 'shell'
            % rotate
            verts = (rotall * verts')';
            % rearrange structure (Nx3 array with xyz coordinates for each unique node)
            stlnodes = unique(verts,'rows');
    end

    %% Determine boundaries
    % determine min/max values for each axis
    gridinfo(1).bounds = [min(stlnodes(:,1)),max(stlnodes(:,1))];
    gridinfo(2).bounds = [min(stlnodes(:,2)),max(stlnodes(:,2))];
    gridinfo(3).bounds = [min(stlnodes(:,3)),max(stlnodes(:,3))];
       
    % number of dots in each direction
    switch type
        case 'solid'
            gridinfo(1).nDot = floor((gridinfo(1).bounds(2) - gridinfo(1).bounds(1)) / cg_res(1));
            gridinfo(2).nDot = floor((gridinfo(2).bounds(2) - gridinfo(2).bounds(1)) / cg_res(2));
            gridinfo(3).nDot = floor((gridinfo(3).bounds(2) - gridinfo(3).bounds(1)) / cg_res(3));
        case 'shell'
            gridinfo(1).nDot = ceil((gridinfo(1).bounds(2) - gridinfo(1).bounds(1)) / cg_res(1))+2;
            gridinfo(2).nDot = ceil((gridinfo(2).bounds(2) - gridinfo(2).bounds(1)) / cg_res(2))+2;
            gridinfo(3).nDot = ceil((gridinfo(3).bounds(2) - gridinfo(3).bounds(1)) / cg_res(3))+2;
    end

    % grid vectors
    switch type
        case 'solid'
            gridinfo(1).vals = [(gridinfo(1).bounds(1)+cg_res(1)/2):cg_res(1):(gridinfo(1).bounds(1)+cg_res(1)/2+(gridinfo(1).nDot-1)*cg_res(1))]';
            gridinfo(2).vals = [(gridinfo(2).bounds(1)+cg_res(2)/2):cg_res(2):(gridinfo(2).bounds(1)+cg_res(2)/2+(gridinfo(2).nDot-1)*cg_res(2))]';
            gridinfo(3).vals = [(gridinfo(3).bounds(1)+cg_res(3)/2):cg_res(3):(gridinfo(3).bounds(1)+cg_res(3)/2+(gridinfo(3).nDot-1)*cg_res(3))]';
        case 'shell'
            gridinfo(1).vals = [(gridinfo(1).bounds(1)-cg_res(1)/2):cg_res(1):(gridinfo(1).bounds(1)+cg_res(1)/2+(gridinfo(1).nDot-2)*cg_res(1))]';
            gridinfo(2).vals = [(gridinfo(2).bounds(1)-cg_res(2)/2):cg_res(2):(gridinfo(2).bounds(1)+cg_res(2)/2+(gridinfo(2).nDot-2)*cg_res(2))]';
            gridinfo(3).vals = [(gridinfo(3).bounds(1)-cg_res(3)/2):cg_res(3):(gridinfo(3).bounds(1)+cg_res(3)/2+(gridinfo(3).nDot-2)*cg_res(3))]';
    end

    %% Load voxel structure
    % load structure
    voxelstructure = VOXELISE(gridinfo(1).vals',gridinfo(2).vals',gridinfo(3).vals',stlfile,type);

    % vectors to display
    varray = voxelstructure(:);
    gridinfo(1).array = uint16(repmat((1:gridinfo(1).nDot)',gridinfo(2).nDot*gridinfo(3).nDot,1));
    gridinfo(2).array = uint16(repmat(repelem((1:gridinfo(2).nDot)',gridinfo(1).nDot),gridinfo(3).nDot,1));
    gridinfo(3).array = uint16(repelem((1:gridinfo(3).nDot)',gridinfo(1).nDot*gridinfo(2).nDot));

    %% Material Assignment
    % set up empty material matrix
    mat = uint16(zeros(size(varray,1),numel(fieldnames(matinfo))-1));
    
    % fill material matrix with void
    mat(:,1) = 10000;

    % assign material IDs to material matrix column
    fnames = fieldnames(matinfo);
    for imat = 1:numel(fnames)-1
        matinfo.col2mat(imat,:) = [imat,matinfo.(fnames{imat}).ID];
    end
    matinfo.mat2col = flip(matinfo.col2mat,2);

    % assign base material
    switch size(matinfo.basemat,2)
        case 1
            % assign homogenous material
            mat(varray == 1,matinfo.mat2col(matinfo.mat2col(:,1)==matinfo.basemat,2)) = 10000;
            mat(varray == 1,1) = 0;
        case 2
            % check if material mixture is valid
            if round(sum(abs(matinfo.basemat(:,2))),6)~=1
                error('Material mixture does not add up to 1. Please check the inputs');
            end
               
            % assign each material in mixture
            for imat = 1:size(matinfo.basemat,1)
                mat(varray == 1,matinfo.mat2col(matinfo.mat2col(:,1)==matinfo.basemat(imat,1),2)) = matinfo.basemat(imat,2)*10000;
                mat(varray == 1,1) = 0;
            end
        case 3
            % calculate amount of AB in AB/VW mixture
            [~,rho,~,Mismatch] = HELPER_GetMasterCurve(matinfo.basemat,[20,80],'Tg');
            % template for material row
            matrow = uint16(zeros(1,size(mat,2)));
            % Material IDs for AB and VW
            matnames = fieldnames(matinfo);
            matnames(end-2:end) = [];
            for iname = 1:length(matnames)
                switch matinfo.(matnames{iname}).Name
                    case 'Agilus'
                        IDAB = matinfo.(matnames{iname}).ID;
                    case 'VeroWhiteUltra'
                        IDVW = matinfo.(matnames{iname}).ID;
                end
            end
            if exist('IDAB')*exist('IDVW')==0
                error('Not both Agilus and VeroWhiteUltra defined.')
            end
            % mat column IDs for AB and VW
            IDABcol = matinfo.mat2col(matinfo.mat2col(:,1)==IDAB,2);
            IDVWcol = matinfo.mat2col(matinfo.mat2col(:,1)==IDVW,2);
            % fill material row
            matrow(IDABcol) = rho*10000;
            matrow(IDVWcol) = (1-rho)*10000;
            % assign each material in mixture
            mat(varray == 1,:) = repmat(matrow,sum(varray),1); 
    end 

    % add basemat row to matinfo
    matinfo.basematRow = mat(find(varray==1,1),:);
    
    end

    % save files
    if strcmp(savemode,'save')
        % make savename
        delimiterpos = strfind(name,filesep);
        if isempty(delimiterpos)
            fname  = name;
            folder = '';
        else
            fname  = name(delimiterpos(end)+1:end);
            folder = name(1:delimiterpos(end));
        end
        fname = fname(1:end-4);
        % make savestruct
        savestruct.gridinfo = gridinfo;
        savestruct.mat      = mat;
        savestruct.matinfo  = matinfo;
        savestruct.stlfile  = stlfile;
        save([folder,'SAVE_',fname,'.mat'],'savestruct');
    end

    % correct file
    correction = 'floatnodes';
    if strcmp(type,'shell') & strcmp(correction,'floatnodes')
        vID = sort(stlfile.faces(:));
        gc  = groupcounts(vID);
        IDloose = find(gc==1);
        if isempty(IDloose)==0
            for IDl = 1:length(IDloose)
                IDf = find(sum(stlfile.faces == IDloose(IDl),2)>0);
                stlfile.faces(IDf,:) = [];
                IDold = (IDloose(IDl)+1:1:length(stlfile.vertices))';
                IDnew = IDold-1;
                stlfile.faces = changem(stlfile.faces,IDnew,IDold);
                stlfile.vertices(IDloose(IDl),:) = [];
                stlfile.centroids(IDf,:) = [];
            end
        end
    end

    % progress report
    fprintf('DONE \n');
end