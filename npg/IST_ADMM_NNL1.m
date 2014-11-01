classdef IST_ADMM_NNL1 < Methods
    properties
        stepShrnk = 0.5;
        preAlpha=0;
        preG=[];
        preY=[];
        thresh=1e-4;
        maxItr=1e3;
        theta = 0;
        admmAbsTol=1e-9;
        admmTol=1e-3;   % abs value should be 1e-8
        cumu=0;
        cumuTol=4;
        newCost;
        nonInc=0;
        innerSearch

        debug = false;

        adaptiveStep=true;
    end
    methods
        function obj = IST_ADMM_NNL1(n,alpha,maxAlphaSteps,stepShrnk,Psi,Psit)
            obj = obj@Methods(n,alpha);
            obj.maxItr = maxAlphaSteps;
            obj.stepShrnk = stepShrnk;
            obj.Psi = Psi; obj.Psit = Psit;
            obj.nonInc=0;
        end
        % solves l(α) + I(α>=0) + u*||Ψ'*α||_1
        % method No.4 with ADMM inside IST for NNL1
        % the order of 2nd and 3rd terms is determined by the ADMM subroutine
        function out = main(obj)
            obj.p = obj.p+1; obj.warned = false;
            pp=0; resetDifAlpha=0;
            while(pp<obj.maxItr)
                pp=pp+1;
                y=obj.alpha;

                [oldCost,obj.grad] = obj.func(y);

                % start of line Search
                obj.ppp=0; temp=true; temp1=0;
                while(true)
                    if(temp && temp1<obj.adaptiveStep && obj.cumu>=obj.cumuTol)
                        % adaptively increase the step size
                        temp1=temp1+1;
                        obj.t=obj.t*obj.stepShrnk;
                        obj.cumu=0;
                    end
                    obj.ppp = obj.ppp+1;
                    newX = y - obj.grad/obj.t;
                    [newX,obj.innerSearch] = FISTA_ADMM_NNL1.innerADMM_v4(obj.Psi,obj.Psit,...
                        newX,obj.u/obj.t,obj.admmTol*obj.difAlpha);
                    obj.newCost=obj.func(newX);
                    if(obj.ppp>20 || obj.newCost<=oldCost+innerProd(obj.grad, newX-y)+sqrNorm(newX-y)*obj.t/2)
                        if(obj.ppp<=20 && temp && obj.p==1)
                            obj.t=obj.t*obj.stepShrnk;
                            continue;
                        else break;
                        end
                    else obj.t=obj.t/obj.stepShrnk; temp=false; obj.cumuTol=obj.cumuTol+2;
                    end
                end
                obj.fVal(3) = pNorm(obj.Psit(newX),1);
                temp = obj.newCost+obj.u*obj.fVal(3);
                if(temp>obj.cost)
                    obj.nonInc=obj.nonInc+1;
                    if(obj.nonInc>5) newX=obj.alpha; end
                end
                if(temp>obj.cost)
                    switch(resetDifAlpha)
                        case 0
                            resetDifAlpha= 1;
                            pp=pp-1;
                            obj.difAlpha=0;
                            continue;
                        otherwise
                            newX=obj.alpha;
                            temp=obj.cost;
                    end
                end
                obj.cost = temp;
                obj.stepSize = 1/obj.t;
                obj.difAlpha = relativeDif(obj.alpha,newX);
                obj.alpha = newX;

                if(obj.ppp==1 && obj.adaptiveStep) obj.cumu=obj.cumu+1;
                else obj.cumu=0; end
                %set(0,'CurrentFigure',123);
                %subplot(2,1,1); semilogy(obj.p,obj.newCost,'.'); hold on;
                %subplot(2,1,2); semilogy(obj.p,obj.difAlpha,'.'); hold on;
                if(obj.difAlpha<=obj.thresh) break; end
            end
            out = obj.alpha;
        end
        function reset(obj)
            obj.theta=0; obj.preAlpha=obj.alpha;
        end
    end
end

