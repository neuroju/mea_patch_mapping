%% LOAD PARALLEL PATCH-CLAMP & SORTED HD-MEA DATA - to be edited by user
% -load vector 'Xt' containing sampling time points (in s) of patch trace
% (typically 20 kHz sampling rate)
% -load vector 'Y' containing the patch-clamp measurements (e.g., current
% trace in pA); same length as 'Xt'
% -load struct 'spikeTimesAllUnits' with fields 'time' and 'unit', vectors
% containing all spike times (in s; ascending) and the corresponding unit ID,
% respectively.


%% DETREND AND DOWNSAMPLE PATCH TRACE
removeT = Xt < spikeTimesAllUnits.time(1) | Xt > spikeTimesAllUnits.time(end);
[Xt1, Y1det, Y1, Bl] = detrendPatch(Xt(~removeT), Y(~removeT), 1);
clear Xt Y;


%% BLOCK SPIKE TIMES FROM EXCLUDED RECORDING PERIODS
blockStartTimes = [0; Xt1(end)];
blockEndTimes = [Xt1(1); spikeTimesAllUnits.time(end)];

stdY = calcMadStd(Y1det');
THR_DOWN = -10*3*stdY;
kinds = find(Y1det < THR_DOWN);

if ~isempty(kinds)
    starti = kinds(1);
    endi = kinds(end);
    startis = [starti; kinds(find(diff(kinds)>1)+1)];
    endis = [kinds(diff(kinds)>1); endi];
    blockStartTimes = [blockStartTimes; Xt1(startis)];
    blockEndTimes = [blockEndTimes; Xt1(endis)];
end

% additional spike time exclusions should there be gaps between sweeps
Xdiff = diff(Xt1);
pSweepTrans = find(Xdiff > 1.1*Xdiff(1));  
blockStartTimes = [blockStartTimes; Xt1(pSweepTrans)];
blockEndTimes = [blockEndTimes; Xt1(pSweepTrans+1)];

% extends blocked regions so spike times too close to borders are removed
MAX_BLOCK_DIST = .12;
blockStartTimes = blockStartTimes - MAX_BLOCK_DIST;
blockEndTimes = blockEndTimes + MAX_BLOCK_DIST;

% determine blocked spike times
blockSpikeIdx = zeros(numel(spikeTimesAllUnits.time), 1);
for be=1:numel(blockStartTimes)
    blockSpikeIdx(find(spikeTimesAllUnits.time>blockStartTimes(be) & spikeTimesAllUnits.time<blockEndTimes(be))) = 1;
end

gdf = [spikeTimesAllUnits.unit(~blockSpikeIdx) spikeTimesAllUnits.time(~blockSpikeIdx)];


%% BUILD SPARSE SPIKE TRAINS
REMOVE_UNITS_WITH_FEWER_SPIKES = 10;
W_LEN = 600;
SHIFT_SPIKES_BY = W_LEN/2-100;

nrUnitsRemoved = 0;
uIDs = unique(gdf(:, 1));
nrSpikesPerUnit = zeros(numel(uIDs), 1);

for i=1:numel(uIDs)
    st = find(gdf(:,1) == uIDs(i));
    nrSpikesPerUnit(i) = numel(st);
    if nrSpikesPerUnit(i) < REMOVE_UNITS_WITH_FEWER_SPIKES
        gdf(gdf(:,1) == uIDs(i),:) = [];
        nrUnitsRemoved = nrUnitsRemoved+1;
        nrSpikesPerUnit(i) = NaN;
    end
end
uIDs = unique(gdf(:,1));

nrSpikesPerUnit(isnan(nrSpikesPerUnit)) = [];

disp(['# included units: ' num2str(numel(uIDs))]);
disp(['# removed units (<' num2str(REMOVE_UNITS_WITH_FEWER_SPIKES) ' spks): ' num2str(nrUnitsRemoved)]);

ST = buildSparseSpikeTrain(Xt1, gdf, SHIFT_SPIKES_BY);


%% ESTIMATE EPSC waveforms
tic
[What, wwsigs] = estimWaveforms(ST, Y1det, W_LEN); 
What = squeeze(What); %  contains the EPSC estimates (one waveform for each unit in the network)
toc