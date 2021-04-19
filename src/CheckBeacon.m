function response = CheckBeacon(marker, allele, beacon)
% read allele from file to table

% matches1 = find(strcmp(FindMarker{:,3}, chromosome));
% matches2 = FindMarker(matches1(:,1),:).pos == position;
% found = find(matches2);

% if found == 0
%     response = 0;
% else
%marker = FindMarker{found, 1};
if ~ismember(marker, beacon.Properties.VariableNames)
    response = 0;
    disp('marker not in beacon')
    return
end
snpss = beacon{:, marker};
% unique(snpss)

%if find(strcmp(snps{:, :}, allele)) % change so that either char 0 (A) or char 1 (T) fit
for i = 1:size(snpss, 1)
    
    if ismember(snpss{i}(1), allele) || ismember(snpss{i}(2), allele)
        
        response = 1;
        return
    end
end
response = 0;

%disp(response)

end