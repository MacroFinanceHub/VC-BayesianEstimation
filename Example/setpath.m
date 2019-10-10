function setpath

% setpath
%
% Set path to codes needed.

pathBase = '../../';
pathList = {...
    'VC-BayesianEstimation',...
    'VC-Tools',...
    'Sims-Gensys',...
    'Sims-KF',...
    'Sims-Optimize',...
    };
for j=1:length(pathList)
    pathAdd{j} = [pathBase,pathList{j}];
end
addpath(pathAdd{:})
