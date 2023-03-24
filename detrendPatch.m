function [Xt, Ydet, Y, B] = detrendPatch(Xt, Y, fineDet)
% Two-step detrending if fineDet is 1

% downsample
srate_org = 20000;
down1 = 4;
Xt = Xt(1:down1:end);
Y = resample(Y, 1, down1);
srate = srate_org/down1;

% careful detrending of very slow baseline drift
stride = 100;
Ymed = medfilt1(Y(1:stride:end), srate, 'omitnan', 'truncate');
Xtmed = Xt(1:stride:end);
Ymed = interp1(Xtmed, Ymed, Xt);
nanIdx = isnan(Ymed);
Ymed(nanIdx) = [];
Y(nanIdx) = [];
Xt(nanIdx) = [];
Ydet = Y-Ymed;
B = Ymed;

if fineDet
    % remove outliers
    medY = median(Ydet);
    stdY = calcMadStd(Ydet');
    YoutRem = Ydet;
    YoutRem(Ydet < medY - 3*stdY | Ydet > medY + 3*stdY) = medY; 

    % dentrending of remaining slow baseline fluctuations
    Ymed2 = medfilt1(YoutRem, 8000, 'omitnan', 'truncate');
    Ydet = Ydet-Ymed2;
    B = B+Ymed2;
end

