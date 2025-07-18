% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function mat = OPERATION_coat(gridinfo,mat,matinfo,coat)
    % progress report
    if coat.mat.in ==  coat.mat.out
        fprintf(['Create coating of thickness ',num2str(coat.thickness),' ... ']);
    else
        fprintf(['Create coating of thickness ',num2str(coat.thickness),' with a "',coat.grad.type,'"  gradient ... ']);
    end

    % read voxel size (xy,z)
    voxelsize = [gridinfo(1).vals(2)-gridinfo(1).vals(1), ...
                 gridinfo(2).vals(2)-gridinfo(2).vals(1), ...
                 gridinfo(3).vals(2)-gridinfo(3).vals(1)];
    
    % factor between xy and z voxelsize
    voxelfac  = voxelsize(1) / voxelsize(2);

    % number of coating voxels in each direction
    ncoat = round(repmat(coat.thickness,1,3) ./ voxelsize);

    % simplify material vector
    mat_simplified = logical(zeros(size(mat,1),1));
    mat_simplified(mat(:,1)==0) = 1;

    % restructure the simplified mat matrix
    mat_3D = reshape(mat_simplified,gridinfo(1).nDot,gridinfo(2).nDot,gridinfo(3).nDot);
    
    % template to store ID of layers
    edgelayers = {};

    % number of coating layers and dimension with largest spacing
    [nlayers,ilarge] = min(ncoat);

    % non-dominant dimensions
    ismall = setdiff([1,2,3],ilarge);

    % iterate through all layers
    for layer = 1:nlayers
        % kernel dimensions
        kdim = zeros(1,3);
        kdim(1,ilarge) = 2*layer+1;
        kdim(1,ismall) = 2*layer*ncoat(ismall)/ncoat(ilarge)+1;

        % make kernel
        kernel = ones(kdim);

        % make convolution
        convolution = convn(mat_3D,kernel,'same');
        
        % flatten
        convolution = convolution(:);
    
        % find points not completely enclosed by points
        ID_edge = find(convolution ~= sum(kernel,'all') & mat_simplified == 1);

        % store in tempplate
        edgelayers{layer} = ID_edge;
    end

    % differentiate layer IDs if thickness if bigger then one layer
    if nlayers>1
        for layer = 1:nlayers-1
            % start from last layer
            currlayer = nlayers - layer + 1;

            % find difference of inner layer to next outer layer
            edgelayers{currlayer} = setdiff(edgelayers{currlayer},edgelayers{currlayer-1});
        end
    end

    % transform material in requirement mode to mixture mode
    if size(coat.mat.out,2)==3
        % calculate amount of AB in AB/VW mixture
        [~,rho,~,Mismatch] = HELPER_GetMasterCurve(coat.mat.out,[20,80],'Tg');
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
        % rename gradient material
        coat.mat.out = [IDAB,rho; IDVW,(1-rho)]
    end
    if size(coat.mat.in,2)==3
        % calculate amount of AB in AB/VW mixture
        [~,rho,~,Mismatch] = HELPER_GetMasterCurve(coat.mat.in,[20,80],'Tg');
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
        % rename gradient material
        coat.mat.in = [IDAB,rho; IDVW,(1-rho)]
    end

    % check if gradient ends are only homogenous material
    onlyhomogenous = size(coat.mat.out,2) == 1 & size(coat.mat.in,2) == 1;

    % % build material interpolation table
    % switch onlyhomogenous
    %     case 1
    %         mat_table = [coat.mat.out,1,0; coat.mat.in,0,1];
    %     case 0
    %         mat_table = [];
    %         if size(coat.mat.out,2)==2
    %             mat_table = [mat_table;coat.mat.out, ...
    %                          zeros(size(coat.mat.out,1),1)];
    %         else
    %             mat_table = [mat_table; coat.mat.out, 1, 0];
    %         end
    % 
    %         if size(coat.mat.in,2)==2
    %             mat_table = [mat_table;coat.mat.in(:,1), ...
    %                          zeros(size(coat.mat.in,1),1), ...
    %                          coat.mat.in(:,2)];
    %         else
    %             mat_table = [mat_table; coat.mat.in, 0, 1];
    %         end
    % end


    % build material interpolation table
    switch onlyhomogenous
        case 1
            if coat.mat.out == coat.mat.in
                mat_table = [coat.mat.out,1,1];
            else
                mat_table = [coat.mat.out,1,0; coat.mat.in,0,1];
            end
        case 0
            IDs = unique([coat.mat.out(:,1);coat.mat.in(:,1)]);
            mat_table = zeros(size(IDs,1),3);
            mat_table(:,1) = IDs;

            if size(coat.mat.out,2)==2
                for n = 1:size(coat.mat.out,1)
                    matID = coat.mat.out(n,1);
                    rowID = find(mat_table(:,1)==matID);
                    mat_table(rowID,2) = coat.mat.out(n,2);                   
                end
            else
                matID = coat.mat.out;
                rowID = find(mat_table(:,1)==matID);
                mat_table(rowID,2) = 1;  
            end
            
            if size(coat.mat.in,2)==2
                for n = 1:size(coat.mat.in,1)
                    matID = coat.mat.in(n,1);
                    rowID = find(mat_table(:,1)==matID);
                    mat_table(rowID,3) = coat.mat.in(n,2);                   
                end
            else
                matID = coat.mat.in;
                rowID = find(mat_table(:,1)==matID);
                mat_table(rowID,3) = 1;  
            end
    end




    % iterate through all layers
    for layer = 1:nlayers
        % current material fraction based on gradient information
        matfrac = HELPER_gradfunction(layer-1,nlayers-1,coat.grad.type,coat.grad.args);
        curr_matfraction = mat_table(:,2) + (mat_table(:,3) - mat_table(:,2)) * matfrac;

        % IDs
        IDs = edgelayers{layer};

        % set rows to zero
        mat(IDs,:) = 0;

        % assign each material in mixture
        for imat = 1:size(mat_table,1)
            mat(IDs,matinfo.mat2col(matinfo.mat2col(:,1)==mat_table(imat,1),2)) = curr_matfraction(imat)*10000;
        end   
    end

    % progress report
    fprintf('DONE \n')
end