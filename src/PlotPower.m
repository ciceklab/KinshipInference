function PlotPower(type, test, queryCount)
    for h=[1,4,6]
        if type == "QI"
            load(strcat(strcat('results/', type), ['__Test=' num2str(test, '%d') '_Type=0.mat']));
            Delta1 = DeltaQI(:, :, :);
            load(strcat(strcat('results/', type), ['__Test=' num2str(test, '%d') '_Type=1.mat']));
            Delta2 = DeltaQI(:, :, :);
        else
            load(strcat(strcat('results/', type), ['__Test=' num2str(test, '%d') '_Type=0.mat']));
            Delta1 = Delta(:, :, :);
            load(strcat(strcat('results/', type), ['__Test=' num2str(test, '%d') '_Type=1.mat']));
            Delta2 = Delta(:, :, :);
        end
        % Calculate Power
        c = zeros(20,queryCount);
        d = zeros(20,queryCount);
        a = squeeze(Delta1(h,:,:));
        b = squeeze(Delta2(h,:,:));
        
        for p = 1:20
            c(p, 1:size(a(p, (a(p, :)~=0)), 2)) = a(p, (a(p, :)~=0));
        end
        
        for p = 1:20
            d(p, 1:size(b(p, (b(p, :)~=0)), 2)) = b(p, (b(p, :)~=0));
        end
        
        power = [zeros(1, 1), ones(1, queryCount)];
        for q = 1:queryCount
            power(1, q+1) = sum(c(c(1:20,q) ~=0,q) < prctile(d(d(1:20,q)~=0,q), 5))/sum(c(1:20,q)~=0);
        end
        
        % Plot Power Curve
        hold on
        
        pp = plot(power(1,1:queryCount));
        ylim([0 1]);
        xlim([0 queryCount]);
        xticks(100:100:500);
        yticks(0:0.2:1);
        set(gcf, 'Position',  [50, 50, 2200, 1000]);    
        xlabel('Number of Queries') 
        ylabel('Power')
        grid on
        hold off;
    end
    fileName = char(strcat(type, ['_Test=' num2str(test, '%d') '.jpg']));
    print('-djpeg','-r1000',fileName)
    close
end
