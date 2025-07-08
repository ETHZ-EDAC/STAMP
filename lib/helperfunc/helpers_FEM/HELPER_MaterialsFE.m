function [FEinfo] = HELPER_MaterialsFE(FEinfo,MasterCurve,uniqueMixID,Tg_mix,rho,mat,matinfo)

%% Load Experimental Materials
% path to saved experimental data
expmat_path = [filesep,'helperfunc',filesep,'helpers_FEM',filesep,'data_materials',filesep];

% Vero White Ultra
FEinfo.Materials.VeroWhiteUltra.Name = 'VeroWhiteUltra';
FEinfo.Materials.VeroWhiteUltra.Density = 1.18e-09;
FEinfo.Materials.VeroWhiteUltra.Poisson = 0.5;
FEinfo.Materials.VeroWhiteUltra.Expansion = [0.000102,40;...
                                             0.000157,80];
FEinfo.Materials.VeroWhiteUltra.LongtermModulus = 8.4688;
FEinfo.Materials.VeroWhiteUltra.C1 = 17.44;
FEinfo.Materials.VeroWhiteUltra.C2 = 51.6;
FEinfo.Materials.VeroWhiteUltra.C3 = 1.8617e4;
FEinfo.Materials.VeroWhiteUltra.Tg = 80;
FEinfo.Materials.VeroWhiteUltra.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.VeroWhiteUltra.Name,'Hyper.csv'));
FEinfo.Materials.VeroWhiteUltra.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.VeroWhiteUltra.Name,'Prony.csv'));

% Agilus 30 Black
FEinfo.Materials.Agilus.Name = 'Agilus';
FEinfo.Materials.Agilus.Density = 1.14e-09;
FEinfo.Materials.Agilus.Poisson = 0.5;
FEinfo.Materials.Agilus.Expansion = [0.000102,40;...
                                     0.000157,80];
FEinfo.Materials.Agilus.LongtermModulus = 0.30;
FEinfo.Materials.Agilus.C1 = 17.44;
FEinfo.Materials.Agilus.C2 = 51.6;
FEinfo.Materials.Agilus.C3 = 2.5011e4;
FEinfo.Materials.Agilus.Tg = 20;
FEinfo.Materials.Agilus.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.Agilus.Name,'Hyper.csv'));
FEinfo.Materials.Agilus.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.Agilus.Name,'Prony.csv'));

% 66.6% AB / 33.3% VW
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Name = 'EXP_Agilus_VeroWhiteUltra_666660ppm';
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Density = 1.1522e-09;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Poisson = 0.5;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Expansion = [0.000102,40;... 
                                                                  0.000157,80];
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.LongtermModulus = 3.0392;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.C1 = 17.44;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.C2 = 51.6;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.C3 = 22128;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Tg = 45;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Name,'Hyper.csv'));
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_666660ppm.Name,'Prony.csv'));

% 33.3% AB / 66.6& VW
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Name = 'EXP_Agilus_VeroWhiteUltra_333330ppm';
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Density = 1.1655e-09;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Poisson = 0.5;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Expansion = [0.000102,40;...
                                                                 0.000157,80];
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.LongtermModulus = 5.6182;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.C1 = 17.44;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.C2 = 51.6;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.C3 = 20075;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Tg = 70;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Name,'Hyper.csv'));
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_333330ppm.Name,'Prony.csv'));

% 50% AB / 50% VW
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Name = 'EXP_Agilus_VeroWhiteUltra_500000ppm';
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Density = 1.16e-09;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Poisson = 0.5;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Expansion = [0.000102,40;... 
                                                                  0.000157,80];
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.LongtermModulus = 5.3369;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.C1 = 17.44;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.C2 = 51.6;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.C3 = 20976;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Tg = 60;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Name,'Hyper.csv'));
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_500000ppm.Name,'Prony.csv'));

% 83.5% AB / 16.5% VW
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Name = 'EXP_Agilus_VeroWhiteUltra_835000ppm';
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Density = 1.1466e-09;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Poisson = 0.5;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Expansion = [0.000102,40;... 
                                                                  0.000157,80];
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.LongtermModulus = 1.0759;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.C1 = 17.44;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.C2 = 51.6;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.C3 = 24223;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Tg = 20;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Name,'Hyper.csv'));
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_835000ppm.Name,'Prony.csv'));

% 16.5% AB / 83.5% VW
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Name = 'EXP_Agilus_VeroWhiteUltra_165000ppm';
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Density = 1.1734e-09;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Poisson = 0.5;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Expansion = [0.000102,40;... 
                                                                  0.000157,80];
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.LongtermModulus = 6.723;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.C1 = 17.44;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.C2 = 51.6;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.C3 = 19294;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Tg = 75;
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Hyperelastic = HELPER_ImportHyper(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Name,'Hyper.csv'));
FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Viscoelastic = HELPER_ImportProny(append(expmat_path,FEinfo.Materials.EXP_Agilus_VeroWhiteUltra_165000ppm.Name,'Prony.csv'));

%% Fit Mixed Material
for irho = 1:length(rho)
    fprintf('Mix Material Fitting %1.0d of %1.0d \n',irho,length(rho));
    C1mix = 17.44;
    C2mix = 51.6;

    if (1-rho(irho)) < 0.163
        C3mix = FEinfo.Materials.Agilus.C3;
    else
        PercolationRatio = (((1-rho(irho))-0.163)^0.5547)/((1-0.163)^0.5547);
        C3mix = (1-PercolationRatio)*FEinfo.Materials.Agilus.C3+PercolationRatio*FEinfo.Materials.VeroWhiteUltra.C3;
    end
    Emix = min(MasterCurve(irho,:),[],2);
    DensityMix = rho(irho)*FEinfo.Materials.Agilus.Density+(1-rho(irho))*FEinfo.Materials.VeroWhiteUltra.Density;
    
    eps = [linspace(0,0.02,6)';linspace(0.02,0.1,25)'];
    eps(7,:)=[];
    HyperMixPercolation = (Emix-FEinfo.Materials.Agilus.LongtermModulus)/FEinfo.Materials.VeroWhiteUltra.LongtermModulus;
    HyperMix = FEinfo.Materials.Agilus.Hyperelastic(:,1)*(1-HyperMixPercolation)+...
               FEinfo.Materials.VeroWhiteUltra.Hyperelastic(:,1)*HyperMixPercolation;
    
    %Fit Prony series
    E_f = [10.^linspace(-15,15,1000)',MasterCurve(irho,:)'];
    [PronyParams,~] = HELPER_PronyFitTime(E_f,Emix,Tg_mix(irho,1),C3mix);

    mixname = ['Mix_Agilus_VeroWhiteUltra_',num2str(rho(irho)*1000000),'ppm'];
    FEinfo.Materials.(mixname).Name             = mixname;
    FEinfo.Materials.(mixname).Density          = DensityMix;
    FEinfo.Materials.(mixname).Poisson          = 0.5;
    FEinfo.Materials.(mixname).Expansion        = [0.000102,40;...
                                                   0.000157,80];
    FEinfo.Materials.(mixname).LongtermModulus  = Emix;
    FEinfo.Materials.(mixname).C1               = C1mix;
    FEinfo.Materials.(mixname).C2               = C2mix;
    FEinfo.Materials.(mixname).C3               = C3mix;
    FEinfo.Materials.(mixname).Tg               = Tg_mix(irho,1);
    FEinfo.Materials.(mixname).Hyperelastic     = [HyperMix(1:end,1),eps(2:end,1)];
    FEinfo.Materials.(mixname).Viscoelastic     = PronyParams(2:end,:);
end

end

