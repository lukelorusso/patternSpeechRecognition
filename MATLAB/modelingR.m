%% MODELING (recursive version, much better)
% Given a struct array Nx1 containing feature matrices about multiple
% instances of a single word in the vocabulary, builds a single feature
% matrix resulting from multivariate Gaussian mixture model (GMM) of input
% feature matrices.
%
%  ARGUMENTS:
%  - instances: a struct array Nx1 with fields {typeClass, MFCC} about
%               multiple instances of a single word in the vocabulary
%
%  OUTPUT:
%  - model: a unique model struct array 1x1 with fields {typeClass, MFCC}
%           for the word of the vocabulary
%
%% Copyright (C) Luca Lorusso 2014 - Sapienza Universita' di Roma
%

%% Initializing data
function [model] = modelingR(instances)
    model = struct('typeClass', instances(1).typeClass);
    
    %% If the number of instances == 1 return the only one feature matrix
    if size(instances, 1) == 1
        model.MFCC = instances.MFCC;
    else
        %% If the number of instances is == 2 do a computation step
        if size(instances, 1) == 2
            model.MFCC = gaussMM(instances(1).MFCC, instances(2).MFCC);
        else
            %% Otherwise # > 2, first check if the number of instances is odd...
            if mod(size(instances, 1), 2) ~= 0 % ...doing a computation step with last two instances...
                instances(end - 1).MFCC = gaussMM(instances(end - 1).MFCC, instances(end).MFCC);
                instances(end) = [];
            end
            %% ...then do a RECURSION
            halfSize = size(instances, 1) / 2;
            A = modelingR(instances(1 : halfSize)); % first half of instances
            B = modelingR(instances(halfSize + 1 : end)); % second half of instances
            model.MFCC = gaussMM(A.MFCC, B.MFCC);
        end
    end
end
