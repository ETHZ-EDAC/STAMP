function [mat,matinfo,outargs] = HELPER_operationpipeline(mat,matinfo,gridinfo,operations)
    % output arguments
    outargs = {};
    % number of operations
    for o = 1:size(operations,2)
        % read type of operation
        optype = fieldnames(operations{o});
        optype = optype{1};
        % run operation based on type
        switch optype
            case 'split'
                mat = OPERATION_split(gridinfo,mat,matinfo,operations{o}.split);
            case 'gradient'
                mat = OPERATION_gradient(gridinfo,mat,matinfo,operations{o}.gradient);
            case 'coat'
                mat = OPERATION_coat(gridinfo,mat,matinfo,operations{o}.coat);
            case 'stencil'
                mat = OPERATION_stencil(gridinfo,mat,matinfo,operations{o}.stencil);
            case 'gensupp'
                [mat,matinfo] = OPERATION_generateSupport(gridinfo,mat,matinfo,operations{o}.gensupp);
        end
        % add arguments
        try
            outargs{length(outargs)+1} = outarg;
        end
    end
end