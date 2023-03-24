**Regression approach to calculate synaptic input (e.g., EPSC) waveform estimates based on paired HD-MEA and patch-clamp recordings of spontaneous activity** 

*INPUT*: Parallel spike trains of the neurons in the network (typically, spike-sorted HD-MEA data) and simultaneously recorded patch-clamp data of spontaneous synaptic activity (e.g., EPSCs recorded in voltage clamp).

*OUTPUT*: For each neuron in the network, an estimate of the postsynaptic current (e.g., EPSC) evoked in the patched cell. This estimate will be relatively flat for unconnected neurons, but will resemble synaptic current waveforms for connected cells.


This procedure was developed as part of the article "*Parallel reconstruction of the excitatory and inhibitory inputs received by single neurons reveals the synaptic basis of recurrent spiking*" (https://www.biorxiv.org/content/10.1101/2023.01.06.523018v2). For an example output, see Fig. 3A.

A strong aspect of the regression approach is its ability to resolve/include recording periods with compound EPSCs as result of temporally overlapping synaptic activation of potentially multiple inputs. Moreover, assuming a comprehensive coverage of network-wide unit spiking, the introduced method should be robust even in the presence of synchronous network activity.



**Major steps**
1. Detrending of the patch-clamp trace
2. Encoding of spike trains in sparse matrix
3. Solving of the regression problem

For the third step, we adopted a function of Pillow et al. 2013 (https://doi.org/10.1371/journal.pone.0062123) that solves the regression problem at hand.


**Requirements**
- get *estimWaveforms* function (https://github.com/pillowlab/BinaryPursuitSpikeSorting)
- get *nearestpoint* function from Matlab file exchange (https://mathworks.com/matlabcentral/fileexchange/8939-nearestpoint-x-y-m)


Following minor adjustments of the code, the procedure can also process other types of patch-clamp recordings of synaptic activity (e.g. IPSCs or PSPs in current-clamp mode).
