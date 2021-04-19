function Attack(Beacon, test_group, queryCount, AFs, LDs, doQI, test_type, control)
    NN = size(Beacon, 1);
    test_size = size(test_group, 1);

    AFs(~ismember(AFs.markerId,  test_group.Properties.VariableNames),:) = [];

    % OPTIMAL ATTACK
    deltan = [];
    error = 0.001;
    Delta = [];
    ns = [];
    markersAsked = {};
    responseALL = [];

    for person = 1:20
        CHR = test_group([person],:);
        markers = transpose(CHR.Properties.VariableNames);
        snps = transpose(CHR{1, :});

        [markers, snps] = FilterBiAllelicNewMethod(AFs, markers, snps);
        old_markers = markers;
        old_snps = snps;
        
        for h = [0, 3, 5]
            markers = old_markers;
            snps = old_snps;
            BeaconResponse = zeros(5, queryCount);

            MAFs = min(AFs{ismember(AFs.markerId, markers), 5}, AFs{ismember(AFs.markerId, markers), 7});
            MAFs = [AFs(ismember(AFs.markerId, markers), 3), array2table(MAFs)];
            [MAFs, indexMAF] = sortrows(MAFs, 2);
            markers = MAFs{:, 1};
            MAFs = table2array(MAFs(:, 2));
            snps = snps(indexMAF);
            MAFs(MAFs==0) = 0.000000001;
            toHide = MAFs < ((h/100));
            markers(toHide) = [];
            snps(toHide) = [];
            MAFs(toHide) = [];
    
            firstn = 1;
            BeaconResponse(5,1) = CheckBeacon(markers(1), snps(1), Beacon);
            indexMarkersAsked = 1;
            Delta(h+1, person, indexMarkersAsked) = sum(log(((1-MAFs(1:1)).^2).*(error^(-1))) + log((error./(1-MAFs(1:1)).^2) .* (1-(1-MAFs(1:1)).^(2*NN))./(1-error.*(1-MAFs(1:1)).^(2*NN-2))).* BeaconResponse(5,1:1)');
            markersAsked(h+1, person, indexMarkersAsked) = markers(1);
            indexMarkersAsked = indexMarkersAsked + 1;
            for i = 2:queryCount 
                if BeaconResponse(5,1) == 0 && firstn == 1
                    ns(h+1, person) = 1;                
                    deltan(end+1) = Delta(end, 1);
                    firstn = 0;
                    ns;
                end
                BeaconResponse(5,i) = CheckBeacon(markers(i), snps(i), Beacon);
                Delta(h+1, person, indexMarkersAsked) = sum(log(((1-MAFs(1:i)).^2).*(error^(-1))) + log((error./(1-MAFs(1:i)).^2) .* (1-(1-MAFs(1:i)).^(2*NN))./(1-error.*(1-MAFs(1:i)).^(2*NN-2))).* BeaconResponse(5,1:i)');

                markersAsked(h+1, person, indexMarkersAsked) = markers(i);
                indexMarkersAsked = indexMarkersAsked + 1;

                if BeaconResponse(5,i) == 0 && firstn == 1
                    ns(h+1, person) = i;                    
                    deltan(end+1) = Delta(end, i);
                    firstn = 0;
                end
            end
            responseALL(h+1, person, 1:5, 1:queryCount) = BeaconResponse(:,1:queryCount);
            s = ['results/Optimal__Test=' num2str(test_type,'%d') '_Type=' num2str(control,'%d') '.mat'];
            save(s, 'ns', 'markersAsked', 'responseALL', 'Delta') 
        end
    end
    if doQI
        %% Query Inference
        DeltaQI = [];
        alreadyAsked = zeros(6, 20, queryCount);
        for h = [0, 3, 5]
            for p = 1:20
                p
                markers = squeeze(markersAsked(h+1, p, 1:queryCount));
                MAFs = min(AFs{ismember(AFs.markerId, markers), 5}, AFs{ismember(AFs.markerId, markers), 7});
                MAFs = [AFs(ismember(AFs.markerId, markers), 3), array2table(MAFs)];
                [MAFs, indexMAF] = sortrows(MAFs, 2);
                markers = MAFs{:, 1};
                MAFs = table2array(MAFs(:, 2));
                MAFs(MAFs==0) = 0.000000001;
                BeaconResponse = squeeze(responseALL(h+1, p, 1:5, 1:queryCount));
                disp('start')
                innersum = 0;

                for i = 1:queryCount
                    if alreadyAsked(h+1, p, i) == 1
                        continue;
                    end
                    if ismember(markers{i}, LDs.Nodes.Name)
                        i
                        nodes = successors(LDs, markers{i});
                        nodes = nodes(ismember(nodes, markers));
                        MAFinner = MAFs(ismember(markers, nodes));
                        nodes{end+1,1} = markers{i};
                        if ~isempty(MAFinner)
                            alreadyAsked(h+1, p, ismember(markers, nodes(1:end-1))) = 1;
                            %%%%%
                            m = size(nodes, 1);
                            summ = zeros(m, 3);
                            for j = 1:m
                                edges = findedge(LDs, nodes{j}, nodes);
                                summ(j, 1) = sum(LDs.Edges.Weight(edges(edges~=0)))/size(edges(edges~=0), 1);
                                summ(j, 2) = size(edges(edges~=0), 1);
                                summ(j, 3) = j;
                            end
                            [~, b] = sort(summ(:,2));
                            summ = summ(b,:);
                            summ = summ(1:int8(m * 0.3),:);
                            [~, idx1] = max(summ(:, 1));
                            idx = summ(idx1, 3);
                            queryM = nodes{idx};
                            nodes = successors(LDs, queryM);
                            nodes = nodes(ismember(nodes, markers));
                            MAFinner = MAFs(ismember(markers, nodes));
                            %                 MAFinner = min(AFs{ismember(AFs.markerId, nodes), 5}, AFs{ismember(AFs.markerId, nodes), 7});
                            if BeaconResponse(5,ismember(markersAsked(h+1, p, 1:queryCount), queryM)) == 0 % BeaconResponse(5, i) == 0
                                innersum = innersum + (sum(log(((1-MAFinner(1:size(MAFinner, 1))).^2).*(error^(-1))) + log((error./(1-MAFinner(1:size(MAFinner, 1))).^2) .* (1-(1-MAFinner(1:size(MAFinner, 1))).^(2*NN))./(1-error.*(1-MAFinner(1:size(MAFinner, 1))).^(2*NN-2))).* zeros(size(MAFinner, 1), 1))*mean(LDs.Edges.Weight(findedge(LDs, queryM, nodes))));
                                disp('no')
                                innersum
                            else
                                innersum = innersum + (sum(log(((1-MAFinner(1:size(MAFinner, 1))).^2).*(error^(-1))) + log((error./(1-MAFinner(1:size(MAFinner, 1))).^2) .* (1-(1-MAFinner(1:size(MAFinner, 1))).^(2*NN))./(1-error.*(1-MAFinner(1:size(MAFinner, 1))).^(2*NN-2))).* ones(size(MAFinner, 1), 1))*mean(LDs.Edges.Weight(findedge(LDs, queryM, nodes))));
                                disp('yes')
                                innersum
                            end
                        end
                    else
                        disp('no neighbor')
                    end
                    DeltaQI(h+1, p, i) = sum(log(((1-MAFs(~(squeeze(alreadyAsked(h+1, p, 1:i))'))).^2).*(error^(-1))) + log((error./(1-MAFs(~(squeeze(alreadyAsked(h+1, p, 1:i))'))).^2) .* (1-(1-MAFs(~(squeeze(alreadyAsked(h+1, p, 1:i))'))).^(2*NN))./(1-error.*(1-MAFs(~(squeeze(alreadyAsked(h+1, p, 1:i))'))).^(2*NN-2))).* BeaconResponse(5,~(squeeze(alreadyAsked(h+1, p, 1:i))'))') + innersum;
                    disp(DeltaQI(h+1, p, i))
                end
            end
        end
        s = ['results/QI__Test=' num2str(test_type,'%d') '_Type=' num2str(control,'%d') '.mat'];
        save(s, 'DeltaQI')
    end
end