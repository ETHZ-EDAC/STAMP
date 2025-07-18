% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function mat = OPERATION_stencil(gridinfo,mat,matinfo,stencil)
    % progress report
    fprintf(['Apply stencil ... ']);

    % load stencil depending on the input type
    switch class(stencil.shape)

        % shape provided as point cloud
        case 'double'
            % create convex hull from given points
            Chull = convhull(stencil.shape);
            
            % load coordinates of facet points
            coord_p1 = stencil.shape(Chull(:,1),:);
            coord_p2 = stencil.shape(Chull(:,2),:);
            coord_p3 = stencil.shape(Chull(:,3),:);
        
            % create a mesh of the convex hull
            meshXYZ = zeros(size(coord_p1,1),size(coord_p1,2),3);
            meshXYZ(:,:,1) = coord_p1;
            meshXYZ(:,:,2) = coord_p2;
            meshXYZ(:,:,3) = coord_p3;
        
            % voxelize the mesh of the hull
            stencil_voxel = VOXELISE(gridinfo(1).vals',gridinfo(2).vals',gridinfo(3).vals',meshXYZ,'solid');
            stencil_voxel = stencil_voxel(:);
        

        % shape provided as STL
        case 'char'
            % check if STL exists
            if exist(stencil.shape) == 2
                % read the STL
                partSTL = READ_stl(stencil.shape);
                
                % voxelize the STL
                stencil_voxel = VOXELISE(gridinfo(1).vals', ...
                                         gridinfo(2).vals', ...
                                         gridinfo(3).vals', ...
                                         partSTL,'solid');
                stencil_voxel = stencil_voxel(:);

            % throw error if file does not exist
            else
                error('STL file could not be found.')
            end

        % throw error if input is false
        otherwise
            error('Stencil can not be created due to false input. Provide the input as path to STL file or point cloud as nx3 matrix.')
    end

    % find the candidate IDs within the stencil
    switch stencil.fillvoid
        case 1
            candidates = find(stencil_voxel == 1);
        case 0
            candidates = find(stencil_voxel == 1 & mat(:,1)==0);
    end

    if isfield(stencil,'blendval')
        if stencil.blendval>0
            % indicate blending
            doblend = true;
            % vector
            mat3D = zeros(size(mat,1),1);
            mat3D(candidates) =  1;
            % replace void entries with nan
            voidColID = matinfo.mat2col(matinfo.mat2col(:,1)==matinfo.void.ID,2);
            IDvoid = find(mat(:,voidColID)==10000);
            if stencil.fillvoid==1
                IDvoid = setdiff(IDvoid,candidates);
            end
            mat3D(IDvoid) = nan;
            % reshape
            mat3D = reshape(mat3D,gridinfo(1).nDot,gridinfo(2).nDot,gridinfo(3).nDot);   
            % kernel
            bdsz = stencil.blendval;
            ksize = 2*bdsz+1;
            kernel = ones(ksize,ksize,ksize)/(ksize*ksize*ksize);
            % padd mat nan values
            mat_nan = padarray(mat3D,[bdsz,bdsz,bdsz],nan,'both');
            % make  average convolution in 3 Dimensions
            conv_full = convn(mat_nan,kernel,'valid');    
            % make average convolution in 2 Dimensions
            k_xp_flat = ones(1,ksize,ksize)/(ksize*ksize);
            conv_xp = convn(mat_nan((1+bdsz):end-bdsz,:,:),k_xp_flat,'valid');
            k_yp_flat = ones(ksize,1,ksize)/(ksize*ksize);
            conv_yp = convn(mat_nan(:,(1+bdsz):end-bdsz,:),k_yp_flat,'valid');
            k_zp_flat = ones(ksize,ksize,1)/(ksize*ksize);
            conv_zp = convn(mat_nan(:,:,(1+bdsz):end-bdsz),k_zp_flat,'valid');
            % make average convolution in 1 Dimension
            k_x_line = ones(ksize,1,1)/ksize;
            conv_xl = convn(mat_nan(:,(1+bdsz):end-bdsz,(1+bdsz):end-bdsz),k_x_line,'valid');
            k_y_line = ones(1,ksize,1)/ksize;
            conv_yl = convn(mat_nan((1+bdsz):end-bdsz,:,(1+bdsz):end-bdsz),k_y_line,'valid');
            k_z_line = ones(1,1,ksize)/ksize;
            conv_zl = convn(mat_nan((1+bdsz):end-bdsz,(1+bdsz):end-bdsz,:),k_z_line,'valid');    
            % fill average matrix by replacing the nan values from high to low
            % dimension
            mat_ass = conv_full;
            mat_ass(isnan(mat_ass)) = conv_xp(isnan(mat_ass));
            mat_ass(isnan(mat_ass)) = conv_yp(isnan(mat_ass));
            mat_ass(isnan(mat_ass)) = conv_zp(isnan(mat_ass));
            mat_ass(isnan(mat_ass)) = conv_xl(isnan(mat_ass));
            mat_ass(isnan(mat_ass)) = conv_yl(isnan(mat_ass));
            mat_ass(isnan(mat_ass)) = conv_zl(isnan(mat_ass));
            % fill corners
            mat_ass(isnan(mat_ass))  = mat3D(isnan(mat_ass));
            % rename
            mat_smooth =  mat_ass;
            mat_smooth_vec = mat_smooth(:);
            % new candidate definition
            candidates = find(mat_smooth_vec>0);
        else
            doblend=false;
        end         
    else
        doblend = false;
    end




    switch doblend
        case 0
            switch size(stencil.mat,2)
                case 1
                    % set rows to zero
                    mat(candidates,:) = 0;
                    % assign material
                    mat(candidates,matinfo.mat2col(matinfo.mat2col(:,1)==stencil.mat,2)) = 10000;  
                case 2
                    % check if material mixture is valid
                    if sum(abs(stencil.mat(:,2)))~=1
                        error('Material mixture does not add up to 1. Please check the inputs');
                    end             
                    % set rows to zero
                    mat(candidates,:) = 0;
                    % assign each material in mixture
                    for imat = 1:size(stencil.mat,1)
                        mat(candidates,matinfo.mat2col(matinfo.mat2col(:,1)==stencil.mat(imat,1),2)) = stencil.mat(imat,2)*10000;
                    end  
                case 3
                    % calculate amount of AB in AB/VW mixture
                    [~,rho,~,Mismatch] = HELPER_GetMasterCurve(stencil.mat,[20,80],'Tg');
                    % template for material row
                    matrow = uint16(zeros(1,size(mat,2)));
                    % Material IDs for AB and VW
                    matnames = fieldnames(matinfo);
                    matnames(end-3:end) = [];
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
                    % set rows to zero
                    mat(candidates,:) = 0;
                    % assign material
                    mat(candidates,:) = repmat(matrow,length(candidates),1);
            end
        case 1
            switch size(stencil.mat,2)
                case 1
                    % add basemat to void entries
                    if doblend
                        % find IDs of replaced void entries
                        IDcandvoid = candidates(ismember(candidates,find(mat(:,1)>0)));
                        % construct basemat row
                        mat(IDcandvoid,:) =  repmat(matinfo.basematRow,length(IDcandvoid),1);
                    end

                    % set rows to zero
                    mat(candidates,:) = uint16(single(mat(candidates,:)).*repmat(1-mat_smooth_vec(candidates),1,size(mat,2)));
                    % assign material
                    mat(candidates,matinfo.mat2col(matinfo.mat2col(:,1)==stencil.mat,2)) = mat(candidates,matinfo.mat2col(matinfo.mat2col(:,1)==stencil.mat,2)) + uint16(10000*mat_smooth_vec(candidates));  
                case 2
                    % check if material mixture is valid
                    if sum(abs(stencil.mat(:,2)))~=1
                        error('Material mixture does not add up to 1. Please check the inputs');
                    end             

                    % add basemat to void entries
                    if doblend
                        % find IDs of replaced void entries
                        IDcandvoid = candidates(ismember(candidates,find(mat(:,1)>0)));
                        % construct basemat row
                        mat(IDcandvoid,:) =  repmat(matinfo.basematRow,length(IDcandvoid),1);
                    end

                    % downscale material indices
                    mat(candidates,:) = uint16(single(mat(candidates,:)).*repmat(1-mat_smooth_vec(candidates),1,size(mat,2)));
                    % assign each material in mixture
                    for imat = 1:size(stencil.mat,1)
                        mat(candidates,matinfo.mat2col(matinfo.mat2col(:,1)==stencil.mat(imat,1),2)) = uint16(single(mat(candidates,matinfo.mat2col(matinfo.mat2col(:,1)==stencil.mat(imat,1),2))) + stencil.mat(imat,2)*10000*mat_smooth_vec(candidates));
                    end  
                    

                case 3
                    % calculate amount of AB in AB/VW mixture
                    [~,rho,~,Mismatch] = HELPER_GetMasterCurve(stencil.mat,[20,80],'Tg');
                    % template for material row
                    matrow = uint16(zeros(1,size(mat,2)));
                    % Material IDs for AB and VW
                    matnames = fieldnames(matinfo);
                    matnames(end-3:end) = [];
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

                    % add basemat to void entries
                    if doblend
                        % find IDs of replaced void entries
                        IDcandvoid = candidates(ismember(candidates,find(mat(:,1)>0)));
                        % construct basemat row
                        mat(IDcandvoid,:) =  repmat(matinfo.basematRow,length(IDcandvoid),1);
                    end
                    
                    % set rows to zero
                    mat(candidates,:) = uint16(single(mat(candidates,:)).*repmat(1-mat_smooth_vec(candidates),1,size(mat,2)) + ...
                                              single(repmat(matrow,length(candidates),1)).*repmat(mat_smooth_vec(candidates),1,size(mat,2)));
            end
    end

    % progress report
    fprintf(['DONE \n']);
end