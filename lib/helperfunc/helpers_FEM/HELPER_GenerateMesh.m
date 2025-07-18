% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function [FEinfo] = HELPER_GenerateMesh(cg_res,gridinfo,mat,matinfo,FEinfo,uniqueMixID,rho,geomName,stlfile,rotation)
    %% Create Nodes and Elements 
    switch FEinfo.ElementType
        case 'solid'
            fprintf('Mesh geometry with tets ... ');
            if strcmp(FEinfo.MeshImport,'') == 0
                load(FEinfo.MeshImport,"Elems","Nodes");
                FEinfo.p = Nodes;
                FEinfo.e_solid = Elems;
            else
                model = femodel(Geometry=geomName);
                model = generateMesh(model,GeometricOrder="linear",Hmax=FEinfo.ElementSettings.ElemSize);
                
                FEinfo.p = model.Geometry.Mesh.Nodes';
                FEinfo.e_solid = model.Geometry.Mesh.Elements';
            end
        case 'shell'
            fprintf('Mesh geometry with shells ... ');
            FEinfo.p = stlfile.vertices;
            FEinfo.e_solid = stlfile.faces;
    end

    %% Rotate Points
    % build rotation matrix
    phi = rotation / 180 * pi;
    rotmat_x = [1,0,0;0,cos(phi(1)),-sin(phi(1));0,sin(phi(1)),cos(phi(1))];
    rotmat_y = [cos(phi(2)),0,sin(phi(2));0,1,0;-sin(phi(2)),0,cos(phi(2))];
    rotmat_z = [cos(phi(3)),-sin(phi(3)),0;sin(phi(3)),cos(phi(3)),0;0,0,1];
    rotall = rotmat_z * rotmat_y * rotmat_x;

    % apply rotation
    FEinfo.p = (rotall * FEinfo.p')';

    %% PreProcess - Exchange support with void
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

    %% Determine Element Centroids and Assign Material
    %generate array of centroids
    switch FEinfo.ElementType
        case 'solid'
            parfor i = 1:size(FEinfo.e_solid,1)
                elementCentroids(i,:) = [mean(FEinfo.p(FEinfo.e_solid(i,:),1)),mean(FEinfo.p(FEinfo.e_solid(i,:),2)),mean(FEinfo.p(FEinfo.e_solid(i,:),3))];
            end
        case 'shell'
            elementCentroids = stlfile.centroids;
    end
    FEinfo.ElementCentroids = elementCentroids;

    %generate array of coarse grid nodes
    coarseNodes = [gridinfo(1).vals(gridinfo(1).array),gridinfo(2).vals(gridinfo(2).array),gridinfo(3).vals(gridinfo(3).array)];
    
    %remove void voxels from the input data
    coarseNodes(mat(:,1)>0,:) = [];
    uniqueMixID(mat(:,1)>0,:) = [];
    mat(mat(:,1)>0,:) = [];
    
    %map the centroids of the tets to the coarse nodes
    Idx = knnsearch(coarseNodes,elementCentroids);
    
    %create material assignment
    FEinfo.mat_FE = mat(Idx,:);
    FEinfo.mixID = uniqueMixID(Idx,:);
    
    %% Create material sets to allow correct section assignment in the input file
    % create material sets
    materialsInModel = unique(FEinfo.mixID);
    for i_mats = 1:size(materialsInModel,1)
        mixname = ['Mix_Agilus_VeroWhiteUltra_',num2str(rho(materialsInModel(i_mats))*1000000),'ppm'];
        FEinfo.SetsMaterial(i_mats,:) = {materialsInModel(i_mats),mixname,find(FEinfo.mixID==materialsInModel(i_mats,1))};
    end

    % progress report
    fprintf('DONE \n');
end

