% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function mat = OPERATION_gradient(gridinfo,mat,matinfo,gradient)
    % progress report
    fprintf(['Create "',gradient.type.name, ...
             '" gradient in coordinate direction ',num2str(gradient.direction), ...
             ' in range [',num2str(gradient.coord.start),',',num2str(gradient.coord.end),'] ... ']);

    % find grid values in the gradient
    gridval_active = gridinfo(gradient.direction).vals(gridinfo(gradient.direction).vals <= gradient.coord.end & ...
                                                       gridinfo(gradient.direction).vals >= gradient.coord.start);
    
    % gradient length
    gradlen = gradient.coord.end - ...
              gradient.coord.start;
    
    % transform material in requirement mode to mixture mode
    if size(gradient.mat.start,2)==3
        % calculate amount of AB in AB/VW mixture
        [~,rho,~,Mismatch] = HELPER_GetMasterCurve(gradient.mat.start,[20,80],'Tg');
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
        % rename gradient material
        gradient.mat.start = [IDAB,rho; IDVW,(1-rho)];
    end
    if size(gradient.mat.end,2)==3
        % calculate amount of AB in AB/VW mixture
        [~,rho,~,Mismatch] = HELPER_GetMasterCurve(gradient.mat.end,[20,80],'Tg');
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
        % rename gradient material
        gradient.mat.end = [IDAB,rho; IDVW,(1-rho)];
    end

    % check if gradient ends are only homogenous material
    onlyhomogenous = size(gradient.mat.start,2) == 1 & size(gradient.mat.end,2) == 1;

    % build material interpolation table
    switch onlyhomogenous
        case 1
            if gradient.mat.start == gradient.mat.end
                mat_table = [gradient.mat.start,1,1];
            else
                mat_table = [gradient.mat.start,1,0; gradient.mat.end,0,1];
            end
        case 0
            IDs = unique([gradient.mat.start(:,1);gradient.mat.end(:,1)]);
            mat_table = zeros(size(IDs,1),3);
            mat_table(:,1) = IDs;

            if size(gradient.mat.start,2)==2
                for n = 1:size(gradient.mat.start,1)
                    matID = gradient.mat.start(n,1);
                    rowID = find(mat_table(:,1)==matID);
                    mat_table(rowID,2) = gradient.mat.start(n,2);                   
                end
            else
                matID = gradient.mat.start;
                rowID = find(mat_table(:,1)==matID);
                mat_table(rowID,2) = 1;  
            end
            
            if size(gradient.mat.end,2)==2
                for n = 1:size(gradient.mat.end,1)
                    matID = gradient.mat.end(n,1);
                    rowID = find(mat_table(:,1)==matID);
                    mat_table(rowID,3) = gradient.mat.end(n,2);                   
                end
            else
                matID = gradient.mat.end;
                rowID = find(mat_table(:,1)==matID);
                mat_table(rowID,3) = 1;  
            end
    end

    % random assignement of material for each slice along the gradient
    for g = 1:size(gridval_active,1)
        % current position of slice
        gridval_curr = gridval_active(g);

        % current material fraction of material 1
        matfrac = HELPER_gradfunction(gridval_curr-gradient.coord.start, ...
                                      gradlen, ...
                                      gradient.type.name, ...
                                      gradient.type.args);

        % all points corresponding to current slice
        ID_gridval_curr = find(gridinfo(gradient.direction).array == find(gridinfo(gradient.direction).vals==gridval_curr) & mat(:,1) == 0);

        % current material fractions
        curr_matfraction = mat_table(:,2) + (mat_table(:,3) - mat_table(:,2)) * matfrac;

        % set rows to zero
        mat(ID_gridval_curr,:) = 0;

        % assign each material in mixture
        for imat = 1:size(mat_table,1)
            mat(ID_gridval_curr,matinfo.mat2col(matinfo.mat2col(:,1)==mat_table(imat,1),2)) = curr_matfraction(imat)*10000;
        end         
    end

    % progress report
    fprintf(['DONE \n']);
end