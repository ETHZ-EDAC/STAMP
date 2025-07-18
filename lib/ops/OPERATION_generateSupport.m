% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function [mat,matinfo] = OPERATION_generateSupport(gridinfo,mat,matinfo,gensupp)
    % progress report
    fprintf(['Generate support structure ... ']);

    % reshape to 3D structure indicate void and material voxels
    fillvec = ones(size(mat,1),1);
    fillvec(mat(:,1)==10000) = 0;
    fillmat = reshape(fillvec,[gridinfo(1).nDot,gridinfo(2).nDot,gridinfo(3).nDot]);

    % find cg points above and below assigned material
    cummat=cumsum(fillmat,3);
    cummat_red=cummat-cummat(:,:,end);
    cummat_sig=sign(cummat_red);

    % void points below and above material
    voidabove = cummat_sig==0  & fillmat==0;
    voidbelow = cummat_sig==-1 & fillmat==0;

    % transform to vectors
    voidabove_vec = voidabove(:);
    voidbelow_vec = voidbelow(:);

    % assign support to void below material
    IDsupp = find(voidbelow_vec==1);
    mat(IDsupp,:) = 0;
    mat(IDsupp,matinfo.mat2col(matinfo.mat2col(:,1)==gensupp.mat,2)) = 10000;

    % add entry to matinfo
    fnames = fieldnames(matinfo);
    for imat = 1:size(fnames,1)
        if isstruct(matinfo.(fnames{imat}))
            if isfield(matinfo.(fnames{imat}),'ID')
                if matinfo.(fnames{imat}).ID == gensupp.mat
                    matinfo.(fnames{imat}).isSupp = 1;
                end
            end            
        end
    end


    
    % figure(); hold on; view(3);
    % [x, y, z] = ind2sub(size(voidabove), find(voidabove == 1));
    % scatter3(x, y, z, '.','blue');
    % [x, y, z] = ind2sub(size(voidbelow), find(voidbelow == 1));
    % scatter3(x, y, z, '.','red');


    % progress report
    fprintf(['DONE \n']);
end