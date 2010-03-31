classdef prtClassKnn < prtClass
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'K-Nearest Neighbor'
        nameAbbreviation = 'KNN'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
    end 
    
    properties
        % General Classifier Properties
        k = 3;
        distanceFunction = @(X1,X2)prtDistanceEuclidean(X1,X2);
        TrainingDataSet = [];
    end
    
    methods
        function Obj = prtClassKnn(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected)
        function Obj = trainAction(Obj,DataSet)
            Obj.TrainingDataSet = DataSet;
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            x = getObservations(PrtDataSet);
            n = PrtDataSet.nObservations;
            
            nClasses = Obj.TrainingDataSet.nClasses;
            uClasses = Obj.TrainingDataSet.uniqueClasses;
            labels = getTargets(Obj.TrainingDataSet);
            y = zeros(n,nClasses);
            
            xTrain = getObservations(Obj.TrainingDataSet);
            memBlock = 1000;
            
            if n > memBlock
                for start = 1:memBlock:n
                    indices = start:min(start+memBlock-1,n);
                    
                    distanceMat = feval(Obj.distanceFunction,xTrain,x(indices,:));
                    
                    [~,I] = sort(distanceMat,1,'ascend');
                    I = I(1:Obj.k,:);
                    L = labels(I)';
                    
                    for class = 1:nClasses
                        y(indices,class) = sum(L == uClasses(class),2);
                    end
                end
            else
                distanceMat = feval(Obj.distanceFunction,xTrain,x);
                
                [~,I] = sort(distanceMat,1,'ascend');
                I = I(1:Obj.k,:);
                L = labels(I)';
                
                for class = 1:nClasses
                    y(:,class) = sum(L == uClasses(class),2);
                end
            end
            
            [Etc.nVotes,Etc.MapGuessInd] = max(y,[],2);
            Etc.MapGuess = uClasses(Etc.MapGuessInd);
            ClassifierResults = prtDataSet(y);
            
        end
        
    end
end