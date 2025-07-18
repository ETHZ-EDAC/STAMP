% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function matfrac = HELPER_gradfunction(coord_grad,length_grad,gradtype,args) 
    % exception: gradient length is zero > output 0.5
    if length_grad == 0
        matfrac = 0.5;
    else
        switch gradtype
            % linar gradient
            case 'linear'
                matfrac = coord_grad/length_grad;
    
            % symmetrical gradient (matfrac=1 for coord_grad=0)
            case 'linsymm'
                matfrac = 1-abs((2*coord_grad-length_grad)/length_grad);
    
            % power law gradient
            case 'power'
                u = coord_grad - length_grad/2;
                matfrac = (0.5 + u/length_grad)^args{1}; 
    
            % sigmoid law
            case 'sigmoid'
                u = coord_grad - length_grad/2;
                if coord_grad < length_grad/2
                    matfrac = 0.5*((length_grad/2 + u)/(length_grad/2))^args{1};
                else                    
                    matfrac = 1-0.5*((length_grad/2 - u)/(length_grad/2))^args{1};
                end
        end
    end
end