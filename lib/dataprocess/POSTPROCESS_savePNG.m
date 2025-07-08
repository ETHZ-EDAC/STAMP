function POSTPROCESS_savePNG(layerheight,dpi,gridinfo,mat,matinfo,FEinfo,stlfile,nameout,smoothbdry,type,addargs)
if isempty(nameout) == 0
    % progress report
    fprintf(['Creating PNGs - Save to folder "',nameout,'" ... \n']);

    %%  Create Directory
    if isdir(['02_out',filesep,nameout]) == 0
        mkdir(['02_out',filesep,nameout]);
    end
    
    %% Check if Image Present
    % retreive all images
    imgarray = {}; 
    counter = 1;
    for iarg = 1:length(addargs)
        argtype = addargs{iarg}.type;
        if strcmp(argtype,'img')
            imgarray{counter} = addargs{iarg};
            counter = counter + 1;
        end
    end
    % set up boolean
    if length(imgarray)>0
        containsimg = 1;
    else
        containsimg = 0;
    end

    %% For Shells - Creat Solid Structure
    if strcmp(type,'shell')
        t=FEinfo.ElementThickness;        

        % free boundaries
        TR = triangulation(stlfile.faces,stlfile.vertices);
        BD = freeBoundary(TR);

        % normal vectors
        vec1 = stlfile.vertices(stlfile.faces(:,2),:)-stlfile.vertices(stlfile.faces(:,1),:);
        vec2 = stlfile.vertices(stlfile.faces(:,3),:)-stlfile.vertices(stlfile.faces(:,1),:);
        nvec = cross(vec1,vec2,2);
        nvec = nvec ./ repmat(vecnorm(nvec,2,2),1,3);

        % find which faces belong to which points
        facesToPoints = sortrows([repmat((1:1:size(stlfile.faces,1))',3,1), stlfile.faces(:)],2);
        nvec_p = [accumarray(facesToPoints(:,2),nvec(facesToPoints(:,1),1),[],@mean), ...
                  accumarray(facesToPoints(:,2),nvec(facesToPoints(:,1),2),[],@mean), ...
                  accumarray(facesToPoints(:,2),nvec(facesToPoints(:,1),3),[],@mean)];
        nvec_p = nvec_p ./ repmat(vecnorm(nvec_p,2,2),1,3);

        % shift points
        pshift_pos = stlfile.vertices + nvec_p * t/2;
        pshift_neg = stlfile.vertices - nvec_p * t/2;

        % make new face set
        IDshift = (size(stlfile.vertices,1)+1:1:2*size(stlfile.vertices,1))';
        fshift  = changem(stlfile.faces,IDshift,(1:1:size(stlfile.vertices,1))');

        % edge face set
        IDBD1 = BD;
        IDBD2 = BD + size(stlfile.vertices,1);
        fedge1 = [IDBD1, IDBD2(:,1)];
        fedge2 = [IDBD1(:,2), IDBD2(:,2), IDBD2(:,1)];

        % assemble
        points_solid = [pshift_pos; pshift_neg];
        faces_solid  = [stlfile.faces; fshift; fedge1; fedge2];    

        % restructure
        stlfile = zeros(size(faces_solid,1),3,3);
        stlfile(:,:,1) = points_solid(faces_solid(:,1),:);
        stlfile(:,:,2) = points_solid(faces_solid(:,2),:);
        stlfile(:,:,3) = points_solid(faces_solid(:,3),:);      
    end

    %% Voxel Structure
    % get nodes of stl file
    stlnodes = unique([stlfile(:,:,1); stlfile(:,:,2); stlfile(:,:,3)],'rows');

    % determine resolution
    xyres = 25.4/dpi;
    zres  = layerheight;

    % determine min/max values for each axis
    vs(1).bounds = [min(stlnodes(:,1)),max(stlnodes(:,1))];
    vs(2).bounds = [min(stlnodes(:,2)),max(stlnodes(:,2))];
    vs(3).bounds = [min(stlnodes(:,3)),max(stlnodes(:,3))];
       
    % number of dots in each direction
    vs(1).nDot = floor((vs(1).bounds(2) - vs(1).bounds(1)) / xyres);
    vs(2).nDot = floor((vs(2).bounds(2) - vs(2).bounds(1)) / xyres);
    vs(3).nDot = floor((vs(3).bounds(2) - vs(3).bounds(1)) / zres);
    
    % grid vectors
    vs(1).vals = [(vs(1).bounds(1)+xyres/2):xyres:(vs(1).bounds(1)+xyres/2+(vs(1).nDot-1)*xyres)]';
    vs(2).vals = [(vs(2).bounds(1)+xyres/2):xyres:(vs(2).bounds(1)+xyres/2+(vs(2).nDot-1)*xyres)]';
    vs(3).vals = [(vs(3).bounds(1)+zres/2):zres:(vs(3).bounds(1)+zres/2+(vs(3).nDot-1)*zres)]';
    
    %% Create PNGs
    % names of all material
    matnames = fieldnames(matinfo);
    matnames(end-3:end) = [];

    % assemble colors and IDs in matrices, check if material is support
    mat_allcolors = [];
    mat_allIDs    = [];
    suppID        = [];
    for matno = 1:size(matnames,1)
        mat_allcolors = [mat_allcolors; matinfo.(matnames{matno,1}).col/255];
        mat_allIDs    = [mat_allIDs;    matinfo.(matnames{matno,1}).ID]; 
        if isfield(matinfo.(matnames{matno,1}),'isSupp')
            if matinfo.(matnames{matno,1}).isSupp == 1
                suppID = [suppID,matinfo.(matnames{matno,1}).ID];
            end
        end
    end

    % material matrix support columns
    suppCol = matinfo.mat2col(ismember(matinfo.mat2col(:,1),suppID),2)';

    % reshape material matrix
    mat3D = uint16(zeros(gridinfo(1).nDot,gridinfo(2).nDot,gridinfo(3).nDot,size(mat,2)));
    for  imat = 1:size(mat,2)
        mat3D(:,:,:,imat) =  reshape(mat(:,imat),gridinfo(1).nDot,gridinfo(2).nDot,gridinfo(3).nDot);
    end

    % make 2D meshgrid
    [XmeshCG,YmeshCG] = meshgrid(gridinfo(1).vals,gridinfo(2).vals);
    XmeshCG = XmeshCG';
    YmeshCG = YmeshCG';

    % loop through all slices
    parfor iz = 1:size(vs(3).vals,1)
        % progress report
        fprintf(['Creating PNG ',num2str(iz),filesep,num2str(size(vs(3).vals,1)),'\n']);

        % voxelise one slice
        vslice = VOXELISE(vs(1).vals',vs(2).vals',vs(3).vals(iz),stlfile,'solid');
        
        % material template
        slicemat = uint16(zeros(size(vslice,1),size(vslice,2),size(mat,2)));

        % closest coarse grid layers to current height
        sortedlayers = sortrows([[1:gridinfo(3).nDot]', abs(gridinfo(3).vals-vs(3).vals(iz))],2);
        IDcg_close   = sort(sortedlayers(1:2,1));
        
        % values of coarse grained grid at current height
        cgval = uint16(zeros(gridinfo(1).nDot,gridinfo(2).nDot,size(mat,2)));
        for imat = 1:size(mat,2) 
            val_deflayer        = int16(mat3D(:,:,IDcg_close(1),imat));
            valdiff_interlayer  = int16(mat3D(:,:,IDcg_close(2),imat))-int16(mat3D(:,:,IDcg_close(1),imat));
            distdiff_interlayer = gridinfo(3).vals(IDcg_close(2))-gridinfo(3).vals(IDcg_close(1));
            interpolation_dist  = vs(3).vals(iz)-gridinfo(3).vals(IDcg_close(1));
            cgval(:,:,imat)     = valdiff_interlayer/distdiff_interlayer*interpolation_dist+val_deflayer;
        end

        % make meshgrid of voxel slice
        [XmeshV,YmeshV] = meshgrid(vs(1).vals,vs(2).vals);
        XmeshV = XmeshV';
        YmeshV = YmeshV';

        % 2D interpolate all materials
        for imat = 1:size(mat,2)
            % curreng CG material slice
            currmat = single(cgval(:,:,imat));
            % make interpolant
            interpolant =  scatteredInterpolant(XmeshCG(:),YmeshCG(:),double(currmat(:)),'linear','linear');
            % calculate interpolated values
            slicemat(:,:,imat) = uint16(reshape(interpolant(XmeshV(:),YmeshV(:)),size(XmeshV)));
        end
        
        % make clear boundaries (assign 100% to void material with over 50%)
        voidColID = matinfo.mat2col(matinfo.mat2col(:,1)==matinfo.void.ID,2);
        if smoothbdry
            voidvox = ~vslice;
        else
            voidvox = slicemat(:,:,voidColID)>=50;
        end
        
        % assign support material
        nonvoid = slicemat;
        nonvoid(:,:,voidColID) = [];
        suppvox  = voidvox==1 & sum(nonvoid,3)>0;
        suppmask = ~repmat(suppvox,1,1,size(slicemat,3));
        slicemat = uint16(single(slicemat) .* suppmask);
        if isempty(suppCol)==0
            slicemat(:,:,suppCol) = uint16(suppvox * 10000);
            voidvox = voidvox - suppvox;
        end        

        % assign void
        voidmask  = ~repmat(voidvox,1,1,size(slicemat,3));
        slicemat  = uint16(single(slicemat) .* voidmask);
        slicemat(:,:,voidColID) = uint16(voidvox * 10000);

        % assign material
        slice_random    = double(slicemat) .* rand(size(slicemat));
        slice_indicator = sign(slice_random - repmat(max(slice_random,[],3),1,1,size(slice_random,3))) + 1;
        matID_template  = repmat(reshape(matinfo.col2mat(:,2),1,1,size(matinfo.col2mat,1)),size(slice_indicator,1),size(slice_indicator,2),1);
        matID_slice     = sum(slice_indicator .* matID_template,3);

        % assign colors
        imslice_rgb = repmat(matID_slice,1,1,3);
        imslice_rgb(:,:,1) = changem(imslice_rgb(:,:,1),mat_allcolors(:,1)',mat_allIDs');
        imslice_rgb(:,:,2) = changem(imslice_rgb(:,:,2),mat_allcolors(:,2)',mat_allIDs');
        imslice_rgb(:,:,3) = changem(imslice_rgb(:,:,3),mat_allcolors(:,3)',mat_allIDs');
          
        % add images
        if containsimg
            % make void template
            voidvox3D = repmat(voidvox,1,1,3);
            for iImg = 1:length(imgarray)
                % current image
                img = imgarray{iImg};
                % layer index for colored layers
                [~,idx_top] = min(abs(vs(3).vals-img.center(3)));
                idx_col = (idx_top-img.nCol+1:idx_top)';
                % layer index for white layers
                idx_wht = (idx_top-(img.nWhite+img.nCol)+1:idx_top-img.nCol)';
                % determine case
                if sum(ismember(idx_col,iz))>0
                    % number of image to copy
                    idx_img = find(ismember(idx_col,iz));
                    % image to copy
                    imglayer = img.collayer(idx_img).png;
                    % permute
                    imglayer = permute(imglayer,[2,1,3]);
                    imglayer = flip(imglayer,2);
                    % point to center on geometr
                    [~,cID_x] = min(abs(vs(1).vals-img.center(1)));
                    [~,cID_y] = min(abs(vs(2).vals-img.center(2)));
                    % image center
                    cID_xImg = floor(size(imglayer,1)/2);
                    cID_yImg = floor(size(imglayer,2)/2);
                    % image cutoffs
                    npGeom_left  = cID_x-1;
                    npImg_left   = cID_xImg-1;
                    npGeom_right = vs(1).nDot-cID_x;
                    npImg_right  = size(imglayer,1)-cID_xImg;
                    npGeom_top   = cID_y-1;
                    npImg_top    = cID_yImg-1;
                    npGeom_bot   = vs(2).nDot-cID_y;
                    npImg_bot    = size(imglayer,2)-cID_yImg;
                    co_left  = max(npImg_left - npGeom_left,0);
                    co_right = max(npImg_right - npGeom_right,0);
                    co_top   = max(npImg_top - npGeom_top,0);
                    co_bot   = max(npImg_bot - npGeom_bot,0);
                    % make cutoff
                    imglayer_co = imglayer(co_left+1:size(imglayer,1)-co_right,co_bot+1:size(imglayer,1)-co_top,:);
                    % corner indices
                    cID_left  = cID_x-(npImg_left-co_left);
                    cID_right = cID_x+(npImg_right-co_right);
                    cID_bot   = cID_y-(npImg_bot-co_bot);
                    cID_top   =cID_y+(npImg_top-co_top);
                    % fill
                    rgb_backup = imslice_rgb;
                    imslice_rgb(cID_left:cID_right,cID_bot:cID_top,:) = imglayer_co;
                    imslice_rgb(voidvox3D==1) = rgb_backup(voidvox3D==1);
                elseif sum(ismember(idx_wht,iz))>0
                    % template
                    whites = zeros(size(img.collayer(1).png));
                    tmpl_r = img.colWhite(1) * ones(size(img.alpha));
                    tmpl_g = img.colWhite(2) * ones(size(img.alpha));
                    tmpl_b = img.colWhite(3) * ones(size(img.alpha));
                    tmpl_r(img.alpha==0) = img.colTP(1);
                    tmpl_g(img.alpha==0) = img.colTP(2);
                    tmpl_b(img.alpha==0) = img.colTP(3);
                    whites(:,:,1) = tmpl_r;
                    whites(:,:,2) = tmpl_g;
                    whites(:,:,3) = tmpl_b;
                    
                    % permute
                    whites = permute(whites,[2,1,3]);
                    whites = flip(whites,2);
                    % point to center on geometr
                    [~,cID_x] = min(abs(vs(1).vals-img.center(1)));
                    [~,cID_y] = min(abs(vs(2).vals-img.center(2)));
                    % image center
                    cID_xImg = floor(size(whites,1)/2);
                    cID_yImg = floor(size(whites,2)/2);
                    % image cutoffs
                    npGeom_left  = cID_x-1;
                    npImg_left   = cID_xImg-1;
                    npGeom_right = vs(1).nDot-cID_x;
                    npImg_right  = size(whites,1)-cID_xImg;
                    npGeom_top   = cID_y-1;
                    npImg_top    = cID_yImg-1;
                    npGeom_bot   = vs(2).nDot-cID_y;
                    npImg_bot    = size(whites,2)-cID_yImg;
                    co_left  = max(npImg_left - npGeom_left,0);
                    co_right = max(npImg_right - npGeom_right,0);
                    co_top   = max(npImg_top - npGeom_top,0);
                    co_bot   = max(npImg_bot - npGeom_bot,0);
                    % make cutoff
                    whites_co = whites(co_left+1:size(whites,1)-co_right,co_bot+1:size(whites,1)-co_top,:);
                    % corner indices
                    cID_left  = cID_x-(npImg_left-co_left);
                    cID_right = cID_x+(npImg_right-co_right);
                    cID_bot   = cID_y-(npImg_bot-co_bot);
                    cID_top   =cID_y+(npImg_top-co_top);
                    % fill
                    rgb_backup = imslice_rgb;
                    imslice_rgb(cID_left:cID_right,cID_bot:cID_top,:) = whites_co;
                    imslice_rgb(voidvox3D==1) = rgb_backup(voidvox3D==1);
                end
            end
        end

        % repeat colors along print direction
        png = repelem(imslice_rgb,2,1,1);
        
        % permute
        png = permute(png,[2 1 3]);
        png = flip(png,1);

        % write png
        imwrite(png,['02_out',filesep,nameout,filesep,'slice_',num2str(iz),'.png'])
    end
end