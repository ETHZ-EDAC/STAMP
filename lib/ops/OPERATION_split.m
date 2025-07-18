% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function mat = OPERATION_split(gridinfo,mat,matinfo,split)
    % progress report
    fprintf(['Split body in coordinate direction ',num2str(split.direction),' at coordinate value ',num2str(split.cord),' ... ']);

    % assign material on the positive side
    switch size(split.mat.pos,2)
        case 1
            % IDs to replace
            IDreplace = gridinfo(split.direction).vals(gridinfo(split.direction).array) >= split.cord & mat(:,1) == 0;
            % set rows to zero
            mat(IDreplace,:) = 0;
            % assign material
            mat(IDreplace,matinfo.mat2col(matinfo.mat2col(:,1)==split.mat.pos,2)) = 10000;
        case 2
            % check if material mixture is valid
            if sum(split.mat.pos(:,2))~=1
                error('Material mixture does not add up to 1. Please check the inputs');
            end
            % IDs to replace
            IDreplace = gridinfo(split.direction).vals(gridinfo(split.direction).array) >= split.cord & mat(:,1) == 0;
            % set rows to zero
            mat(IDreplace,:) = 0;
            % assign each material in mixture
            for imat = 1:size(split.mat.pos,1)
                mat(IDreplace,matinfo.mat2col(matinfo.mat2col(:,1)==split.mat.pos(imat,1),2)) = split.mat.pos(imat,2)*10000;
            end  
        case 3
            % calculate amount of AB in AB/VW mixture
            [~,rho,~,Mismatch] = HELPER_GetMasterCurve(split.mat.pos,[20,80],'Tg');
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
            % IDs to replace
            IDreplace = gridinfo(split.direction).vals(gridinfo(split.direction).array) >= split.cord & mat(:,1) == 0;
            % set rows to zero
            mat(IDreplace,:) = 0;
            % assign material
            mat(IDreplace,:) = repmat(matrow,length(IDreplace),1);
    end

    % assign material on the negative side
    switch size(split.mat.neg,2)
        case 1
            % IDs to replace
            IDreplace = gridinfo(split.direction).vals(gridinfo(split.direction).array) < split.cord & mat(:,1) == 0;
            % set rows to zero
            mat(IDreplace,:) = 0;
            % assign material
            mat(IDreplace,matinfo.mat2col(matinfo.mat2col(:,1)==split.mat.neg,2)) = 10000;
        case 2
            % check if material mixture is valid
            if sum(split.mat.neg(:,2))~=1
                error('Material mixture does not add up to 1. Please check the inputs');
            end
            % IDs to replace
            IDreplace = gridinfo(split.direction).vals(gridinfo(split.direction).array) < split.cord & mat(:,1) == 0;
            % set rows to zero
            mat(IDreplace,:) = 0;
            % assign each material in mixture
            for imat = 1:size(split.mat.neg,1)
                mat(IDreplace,matinfo.mat2col(matinfo.mat2col(:,1)==split.mat.neg(imat,1),2)) = split.mat.neg(imat,2)*10000;
            end  
        case 3
            % calculate amount of AB in AB/VW mixture
            [~,rho,~,Mismatch] = HELPER_GetMasterCurve(split.mat.neg,[20,80],'Tg');
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
            % IDs to replace
            IDreplace = gridinfo(split.direction).vals(gridinfo(split.direction).array) < split.cord & mat(:,1) == 0;
            % set rows to zero
            mat(IDreplace,:) = 0;
            % assign material
            mat(IDreplace,:) = repmat(matrow,length(IDreplace),1);
    end

    % progress report
    fprintf(['DONE \n']);
end