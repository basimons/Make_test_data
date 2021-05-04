%Script to make plot like sebastian showed.
%% Load
addpath(genpath('C:\Users\Bram\Documents\TU\Master\MEP\Programs\npy-matlab\npy-matlab'))
clims = [-500,500];


fs = 30e3;
load cmap.mat
fn = 'RawFile.bin';
fid = fopen(fn, 'r');
data = fread(fid, [374 Inf], '*int16');
fclose(fid);
chanMap = readNPY('channel_map.npy');
dat = data(chanMap+1,:);
figure; imagesc(dat(:,1:1500),clims)
col = colorbar;
colormap(cmap)

STemplates = readNPY('spike_templates.npy');  % Which Template used to identify cluster, should be the same as clusters
Winv = readNPY('whitening_mat_inv.npy');      %Import Inverse whitening matrix  nChannels x nChannels
times = readNPY('spike_times.npy');           %Read spikes
Clusters = readNPY('spike_clusters.npy');
% princFeat = readNPY('pc_features.npy');       % nSpikes x nFeatures x nLocalChannels
% princFeatInd = readNPY('pc_feature_ind.npy'); % nTemplates x nLocalChannels
% coords = readNPY('channel_positions.npy');    % x,y coordinates of probes
% Ycoords = coords(:,2); Xcoords = coords(:,1); % Y- and X coordinates.
Templates = readNPY('templates.npy');           %Import templates nTemplates x nTimepoints x nChannels
Channelsmap = readNPY('channel_map.npy');



%%
%%Filter data and get relevant data

%Unwhiten matrix
tempsNW = zeros(size(Templates));
for t = 1:size(Templates)
    tempsNW(t,:,:) = squeeze(Templates(t,:,:)) * Winv;
end

% The amplitude on each channel is the positive peak minus the negative
tempChanAmps = squeeze(max(tempsNW,[],2))-squeeze(min(tempsNW,[],2));

[~,max_site] = max(max(abs(tempsNW),[],2),[],3); % the maximal site for each template
Ssites = uint16(max_site(STemplates+1));

%%
N = 3000;       %Amount of samples to show in figure, sampling rate is 30 kHz

%%Convert data to double and multiply by 2.34 (microVolt).
Data_co = double(dat(:,1:N)) * 2.34;  % so now values are in microVolts


% Data is already highpass filtered on probe, should I do it again?
% Apparently yes, but you can also use other filter frequencies.
% Bandbass filter
Data_filtered = bandpass(Data_co,[300 3000], fs);



                              
clipp = nnz(times <= N);
figure;

imagesc(Data_filtered(:,1:N),clims)
xlabel('$Time$ [ms]','Interpreter','latex','Fontsize',17); 
ylabel('$Channel$ $Number$ [-]','Interpreter','latex','Fontsize',17); 

col = colorbar;
colormap(cmap)
ylabel(col,'$Measured$ $Potential$ [$\mu$V]','Interpreter','latex','Fontsize',17)
set(gcf,'position',[150,150,1500,350])
v = 0:150:N;
xticks(v)
xticklabels(v/30)



Clusscaled = zeros(N,1,'uint8'); 
Clusscaled = uint8(Clusters(1:N,1));


for i= 1:1:clipp
    rectangle('Position', [times(i)-5 Ssites(i)-5 10 10],'EdgeColor', [0, 0, Clusscaled(i)]);
end


%%

Temp_num = 150;

figure;

%for i = 1:size(Templates,3)
for i = 1:50
    hold on
    plot(1:size(Templates,2), Templates(Temp_num,:,i) + i * 10e-3)
end

figure; imagesc(squeeze(Templates(Temp_num,:,:))')






