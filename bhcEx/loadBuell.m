function [y,Phi,Phit,Psi,Psit,opt,FBP]=loadBuell(opt)
    y=load('buell_1a225.mat');
    y=y.data;
    y=y-min(y(:));

    [N,M]=size(y);

    if(~exist('opt','var') || ~isfield(opt,'prjFull')) opt.prjFull=M; end
    if(~isfield(opt,'prjNum')) opt.prjNum=opt.prjFull; end

    theta = (0:(opt.prjNum-1))*M/opt.prjFull +1;
    y=y(:,theta);

    conf=ConfigCT();

    daub = 2; dwt_L=9;        %levels of wavelet transform
    maskType='CircleMask';

    conf.PhiMode = 'gpuPrj'; %'parPrj'; %'basic'; %'gpuPrj'; %
    conf.imgSize = 2^floor(log2(N));
    conf.prjWidth = N;
    conf.prjFull = opt.prjFull;
    conf.prjNum = opt.prjNum;
    conf.dSize = conf.imgSize/conf.prjWidth;
    conf.effectiveRate = 1;
    conf.Ts =1e-2;
    conf.dist = 7765*opt.prjFull/conf.imgSize;

    if(strcmp(maskType,'CircleMask'))
        % reconstruction mask (which pixels do we estimate?)
        mask = Utils.getCircularMask(conf.imgSize);
        wvltName = sprintf('MaskWvlt%dCircleL%dD%d.mat',conf.imgSize,dwt_L,daub);
        if(exist(wvltName,'file'))
            load(wvltName);
        else
            maskk=wvltMask(mask,dwt_L,daub,wvltName);
        end
    else
        mask = []; maskk=[];
    end
    [Phi,Phit,FBP]=conf.genOperators(mask);
    [Psi,Psit]=Utils.getPsiPsit(daub,dwt_L,mask,maskk);
    opt.mask=mask; opt.maskk=maskk;

    fprintf('Configuration Finished!\n');
end

