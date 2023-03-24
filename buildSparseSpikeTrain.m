function ST = buildSparseSpikeTrain(Xt, gdf, SHIFT_SPIKES_BY)

SHIFT_IN_TIME = Xt(SHIFT_SPIKES_BY+1)-Xt(1);
gdf(:,2) = gdf(:,2) + SHIFT_IN_TIME;
gdf(gdf(:,2) > Xt(end),:) = [];

nX = numel(Xt);
uIDs = unique(gdf(:,1));
nUnits = numel(uIDs);
ST = sparse(zeros(nX, nUnits));
count = 0;
for ui=1:nUnits
    st = gdf(gdf(:,1) == uIDs(ui),2);

    % round spike train in sec to samples in new sampling rate
    st = nearestpoint(st, Xt);
    count = count+1;
    ST(st,count) = 1;        
end
ST(:,count+1:end) = [];