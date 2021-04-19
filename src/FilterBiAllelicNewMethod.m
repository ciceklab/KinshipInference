function [markers, snps] = FilterBiAllelicNewMethod(alleleFrequency, markers, snps)
% 
% load('baba_cocuk_ortak.mat');

positions = [];
for i = 1:size(snps)
    alleles = snps{i};
    if size(alleles, 2) == 1
        positions = [positions, i];
    elseif alleles(1) == alleles(2)
        positions = [positions, i];
    end
end

minor = alleleFrequency.referenceAlleleFrequency < 0.5;
inMarkers1 = ismember(markers, alleleFrequency{minor, 3});
%snps(inMarkers1) = alleleFrequency{minor, 4};
snps(inMarkers1) = alleleFrequency{inMarkers1, 4}; %ben

major = alleleFrequency.referenceAlleleFrequency >= 0.5;
inMarkers2 = ismember(markers, alleleFrequency{major, 3});
%snps(inMarkers2) = alleleFrequency{major, 6};
snps(inMarkers2) = alleleFrequency{inMarkers2, 6}; %ben

markers(positions) = [];
snps(positions) = [];

% markers(positions) = [];
% snps(positions) = [];
% 
% for j = 1:size(snps)
%     minor = alleleFrequency.referenceAlleleFrequency < 0.5;
%     af1 = ismember(alleleFrequency.markerId, markers(j));
%     if alleleFrequency{af1, 5} < 0.5
% 
%         snps(j) = alleleFrequency{af1, 4};
%     else
%         snps(j) = alleleFrequency{af1, 6};
% 
% end

end