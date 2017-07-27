function VD=MCMCVDFcn(xd,nShockVar,idxVars,FileName,isObsMats,...
  nHorizons,idxMat,MaxHorizon,VDHorizons,isInfHorizon,isSilent)

% MCMCVDFcn
%
% Used by MCMCVD
%
% See also:
% SetDSGE, GenSymVars, DataAnalysis, PriorAnalysis, GenPost, MaxPost, 
% MakeTableMaxPost, MCMC, MCMCSearchScaleFactor, MakePlotsMCMCConv, 
% MCMCInference, MakeTableMCMCInference, MakePlotsMCMCTrace, 
% MakePlotsMCMCPriorPost, MCMCConv, MakeTableMCMCConv, MCMCVD
% .........................................................................
%
% Created: April 15, 2010 by Vasco Curdia
% Updated: July 26, 2011 by Vasco Curdia
% 
% Copyright 2010-2011 by Vasco Curdia

%% ------------------------------------------------------------------------

nVars = length(idxVars);
nDraws = size(xd,2);
VD = zeros(length(idxVars),nShockVar,nHorizons,nDraws);

for jd=1:nDraws
  %% Obtain Matrices
  eval(sprintf('Mats = %s(xd(:,%i),isObsMats,1);',FileName,jd));
%     for jp=1:np, eval(sprintf('%s = xd(jp,jd);',Params(jp).name)), end
% %     Omegaj = diag(xd(end-nShockVar+1:end,jd));
% %     CFomegaa = CFomegaa+.5;
%     GammaBarj = eval(Mats.StateEq.GammaBar);
%     Gamma0j = eval(Mats.StateEq.Gamma0);
%     Gamma1j = eval(Mats.StateEq.Gamma1);
%     Gamma2j = eval(Mats.StateEq.Gamma2);
%     Gamma4j = eval(Mats.StateEq.Gamma4);
%     Gamma3j = eye(nStateVar);
% %     Gamma2j = Gamma2j*chol(Omegaj)';
%     cv = (all(Gamma0j(1:nStateVar,:)==0,2)~=0);
%     Gamma0j(cv,:) = -Gamma1j(cv,:);
%     Gamma1j(cv,:) = Gamma4j(cv,:);
%     Gamma3j(:,cv) = [];
%     if ~all(all(Gamma4j(~cv,:)==0,2)),error('Incorrect system reduction'),end
%     [G1j,GBarj,G2j,fmat,fwt,ywt,gev,eu]=vcgensys(Gamma0j,Gamma1j,GammaBarj,Gamma2j,Gamma3j);
  for js=1:nShockVar
    Vs = Mats.REE.G2*idxMat(:,js)*idxMat(js,:)*Mats.REE.G2';
    for jh=2:MaxHorizon
      Vs(:,:,jh) = Mats.REE.G1*Vs(:,:,jh-1)*Mats.REE.G1'+Vs(:,:,1);
    end
    Vs = Vs(:,:,VDHorizons(1:end-isInfHorizon));
    if isInfHorizon
      Vs(:,:,nHorizons) = real(lyapcsdSilent(Mats.REE.G1,Vs(:,:,1),isSilent));
    end
    if isObsMats>0
      for jh=1:nHorizons
        Vo(:,:,jh) = Mats.ObsEq.H*Vs(:,:,jh)*Mats.ObsEq.H';
      end
    end
    for jh=1:nHorizons
      vd = diag(Vs(:,:,jh));
      if isObsMats>0
        vd = [vd;diag(Vo(:,:,jh))];
      end
      VD(:,js,jh,jd) = vd(idxVars);
    end
  end
  VD(:,:,:,jd) = abs(VD(:,:,:,jd)./repmat(sum(VD(:,:,:,jd),2),[1,nShockVar,1,1]));
end