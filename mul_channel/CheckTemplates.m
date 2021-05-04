%%
fid = fopen('RawFile.bin','rb');
data = fread(fid,'*int16');
fclose(fid);

len = length(data)/374;

data = reshape(data, [374, len]);
figure;
imagesc(data(:,1:500));
Templates = readNPY('templates.npy');
STemplates = readNPY('spike_templates.npy');  % Which Template used to identify cluster, should be the same as clusters
Winv = readNPY('whitening_mat_inv.npy');      %Import Inverse whitening matrix  nChannels x nChannels
times = readNPY('spike_times.npy');           %Read spikes
Clusters = readNPY('spike_clusters.npy');

%Unwhiten matrix
tempsNW = zeros(size(Templates));
for t = 1:size(Templates)
    tempsNW(t,:,:) = squeeze(Templates(t,:,:)) * Winv;
end

amnt = size(times,1);

% The amplitude on each channel is the positive peak minus the negative
tempChanAmps = squeeze(max(tempsNW,[],2))-squeeze(min(tempsNW,[],2));

[~,max_site] = max(max(abs(tempsNW),[],2),[],3); % the maximal site for each template

Ssites = uint16(max_site(STemplates+1));

Clusscaled = zeros(amnt,1,'uint8'); 
Clusscaled = uint8(Clusters(1:amnt,1));

for i= 1:1:amnt
    rectangle('Position', [times(i)-5 Ssites(i)-5 10 10],'EdgeColor', [0, 0, Clusscaled(i)]);
end



%%

main_kilosort1

%%
main_kilosort2

%%
main_kilosort3


%%
Temps = readNPY('templates.npy');

figure
for i = 1:9
    subplot(3,3,i);
    imagesc(squeeze(Temps(i,:,:))');
    title('template: ' + string(i))
    hold on
    
end

%%
chanmap = readNPY('channel_map.npy');
chanmap = chanmap';
writeNPY(chanmap,'channel_map.npy');
