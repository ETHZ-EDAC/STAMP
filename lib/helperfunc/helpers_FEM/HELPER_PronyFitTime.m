function [PronyParams,N] = HELPER_PronyFitTime(E_t,E_longterm,Tg,C3mix)
%% Settings
plottingBool = 0;
FittingTemp = 22;

%% Define Relevant Variables and Number of Prony Elements Based on Frequency Scale
t=E_t(:,1);
E1=E_t(:,2);
E_initial=max(E1);
E_median = (E_longterm+E_initial)/2;
[~,closestIndex] = min(abs(E1-E_median));
median = floor(log10(t(closestIndex))); 

maxTime = max(floor(log10(t)));
minTime = min(floor(log10(t)));
N = (maxTime-minTime)+1;

timeInitial = linspace(minTime,maxTime,(maxTime-minTime)+1);

%% Set Up Optimization Inputs
x0=[flip((normpdf(linspace(minTime,maxTime,N),median,4)/(sum(normpdf(linspace(minTime,maxTime,N),median,4))))*E_initial),...
    ones(1,N)];

LB = [zeros(1,N),repmat(0.001,1,N)];
UB = [repmat(E_initial,1,N),repmat(1000,1,N)];

t_fit = log10(t);

objFunProny = @(x)(HELPER_ObjPronySeriesTime([x,flip(-timeInitial)],E_longterm,t_fit,E1,N));

%% Prony Fitting Using lsqnonlin
options = optimset('Algorithm','interior-point','TolFun',1e-10,'TolX',1e-10,'Display','off','UseParallel',true,'MaxFunEvals',10000);

[PronyParams_Opt,~,~,~,~] = lsqnonlin(objFunProny,x0,LB,UB,options);

PronyParams_Opt = [PronyParams_Opt,flip(-timeInitial)]';
aT_Fit=10.^(C3mix.*(1./(FittingTemp+273.15)-1./(Tg+273.15)));
PronyParams = [E_longterm,0,0;PronyParams_Opt(1:N,:)/(E_longterm+sum(PronyParams_Opt(1:N,:))),zeros(N,1),(PronyParams_Opt(N+1:2*N,:).*10.^PronyParams_Opt(2*N+1:3*N,:))./aT_Fit];

%% **************************************************************************
    if plottingBool == 1
        nexttile;
        fitresultProny = zeros(size(E1,1),1);
        fitresultProny(:,1) = repmat(E_longterm,size(E1,1),1);
        for j = 1:N
            fitresultProny(:,1) = fitresultProny(:,1) + PronyParams_Opt(j)*exp(-10.^t_fit/(PronyParams_Opt(j+N)*10^PronyParams_Opt(j+2*N)));
        end
        plot(t_fit,fitresultProny,t_fit,E1)
        set(gca,'TickLabelInterpreter','latex','FontSize',12,'LineWidth',1);
        set(groot, 'DefaultLegendInterpreter', 'latex');
        xlabel('log10(f) [Hz]','interpreter','latex')
        ylabel('E'' [MPa]','interpreter','latex')
        pbaspect([2 2 1]);
        grid on
    else
        fitresultProny = 0;
    end
end