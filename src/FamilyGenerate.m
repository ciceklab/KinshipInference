clc;
clear;

for i = 1:20
    i
    
    load(['/home/miray/inference/yeniSnpInfer/Data/famGen_newFamilies_v2/Control/beacon_index' int2str(i) '_Person_new20.mat']);
    
    x = zeros(length(m_new), 4);
    x(:,1) = m_new(:,1);
    x(:,2) = m_new(:,3);
    m = x;
    
%     load(['/home/miray/inference/yeniSnpInfer/Data/Case/beacon_index' int2str(i) '_Person_new.mat']);

    load('/home/miray/inference/yeniSnpInfer/Data/miray_maf_2.mat');


    [IDs,ia,ib] = intersect(maf(:,1), m(:,1));
    maf_new = maf(ia,:);
    m_new = m(ib,:);


    for j = 1:length(m_new)
        
%         j
     
       if(m_new(j,2) == 2)  % aa
      
         pos1 = maf_new(j,4) * maf_new(j,4);
         pos2 = maf_new(j,4) * maf_new(j,3);
         pos3 = maf_new(j,3) * maf_new(j,4);
         pos4 = maf_new(j,3) * maf_new(j,3);
         pos_total = [pos1, pos2, pos3, pos4 ];
         
         poss_normal = pos_total ./ sum(pos_total) ;
         
         if(length(find(isnan(poss_normal))) == length(poss_normal))
            random = randi([1,4]);
            index = random;
         
         else
                      
            random = rand(1);

            subs = abs(poss_normal - random);
            minValue = min(subs);

            index = find(subs(1,:) == minValue);
         end
        
        if(index(1,1) == 1)
            m_new(j,3) = 2;
            m_new(j,4) = 2;
        elseif(index(1,1) == 2)
            m_new(j,3) = 2;
            m_new(j,4) = 1;
        elseif(index(1,1) == 3)
            m_new(j,3) = 1;
            m_new(j,4) = 2;
        else
            m_new(j,3) = 1;
            m_new(j,4) = 1;
        end
          
     elseif(m_new(j,2) == 1) %hetero (1)
         pos1 = maf_new(j,4) * maf_new(j,3);
         pos2 = maf_new(j,4) * maf_new(j,2);
         pos3 = maf_new(j,3) * maf_new(j,4);
         pos4 = maf_new(j,3) * maf_new(j,3);
         pos5 = maf_new(j,3) * maf_new(j,2);
         pos6 = maf_new(j,2) * maf_new(j,4);
         pos7 = maf_new(j,2) * maf_new(j,3);
         
         pos_total = [pos1, pos2, pos3, pos4, pos5, pos6, pos7 ];
         
         poss_normal = pos_total ./ sum(pos_total) ;
         
          if(length(find(isnan(poss_normal))) == length(poss_normal))
            random = randi([1,7]);
            index = random;
         
         else
         
            random = rand(1);

            subs = abs(poss_normal - random);
            minValue = min(subs);

            index = find(subs(1,:) == minValue);
          end
        
        if(index(1,1) == 1)
            m_new(j,3) = 2;
            m_new(j,4) = 1;
        elseif(index(1,1) == 2)
            m_new(j,3) = 2;
            m_new(j,4) = 0;
        elseif(index(1,1) == 3)
            m_new(j,3) = 1;
            m_new(j,4) = 2;
        elseif(index(1,1) == 4)
            m_new(j,3) = 1;
            m_new(j,4) = 1;
        elseif(index(1,1) == 5)
            m_new(j,3) = 1;
            m_new(j,4) = 0;
         elseif(index(1,1) == 6)
            m_new(j,3) = 0;
            m_new(j,4) = 2;    
         elseif(index(1,1) == 7)
            m_new(j,3) = 0;
            m_new(j,4) = 1;    
        end
        
     else   %AA
         pos1 = maf_new(j,3) * maf_new(j,3);
         pos2 = maf_new(j,3) * maf_new(j,2);
         pos3 = maf_new(j,2) * maf_new(j,3);
         pos4 = maf_new(j,2) * maf_new(j,2);
         pos_total = [pos1, pos2, pos3, pos4 ];
         
         poss_normal = pos_total ./ sum(pos_total) ;
         
         
         if(length(find(isnan(poss_normal))) == length(poss_normal))
            random = randi([1,4]);
            index = random;
         
         else
            random = rand(1);

            subs = abs(poss_normal - random);
            minValue = min(subs);

            index = find(subs(1,:) == minValue);
         end
        
          
        if(index(1,1) == 1)
            m_new(j,3) = 1;
            m_new(j,4) = 1;
        elseif(index(1,1) == 2)
            m_new(j,3) = 1;
            m_new(j,4) = 0;
        elseif(index(1,1) == 3)
            m_new(j,3) = 0;
            m_new(j,4) = 1;
        else
            m_new(j,3) = 0;
            m_new(j,4) = 0;
        end
        
      end
     
     
    end
    
     
    fileName = ['/home/miray/inference/yeniSnpInfer/Data/famGen_newFamilies_v2/Control/beacon_index' int2str(i) '_Person_AnneAile_new20.mat'];
    save(fileName, 'm_new');
 

    
end

