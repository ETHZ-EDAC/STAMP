% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function obj = HELPER_ObjPronySeriesTime(x,E_longterm,t_fit,E1,N)
    obj = zeros(size(E1,1),1);
    obj(:,1) = repmat(E_longterm,size(E1,1),1);
    for j = 1:N
        obj(:,1) = obj(:,1) + x(j)*exp(-10.^t_fit/(x(j+N)*10^x(j+2*N)));
    end
    obj = sum((obj-E1).^2);
end