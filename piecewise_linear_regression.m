function [big_linearray, big_wave_array] =  piecewise_linear_regression()
    
    


     load('recent_btc_price.mat')

     Am = table2array(Untitled);
     xv = Am(:,2);
     plot(xv) 
      
    btcdata = readtable('newa.xlsx');
    price = cellfun(@str2double,btcdata{:,1});
    price_withTrend = price(1:end);
    price_withTrend = [price_withTrend; xv];
    t = 1:length(price_withTrend);

    figure
    plot(t,price_withTrend)
    title('Signal with a Trend')
    xlabel('Time Samples');
    ylabel('Price')
    legend('Trended Signal')
    grid on

    % Finding QRS-Complex
    [~,locs_Rwave] = findpeaks(price_withTrend,'MinPeakProminence',3);
    [~,locs_Swave] = findpeaks(-price_withTrend,'MinPeakProminence',2);
    [~,locs_Qwave] = findpeaks(price_withTrend,'MinPeakProminence',2);
    [~,locs_lilQwave] = findpeaks(price_withTrend,'MinPeakProminence',1);

    figure
    hold on 
    plot(t,price_withTrend)
    plot(locs_Rwave,price_withTrend(locs_Rwave),'rv','MarkerFaceColor','r')
    plot(locs_Swave,price_withTrend(locs_Swave),'rs','MarkerFaceColor','b')
    plot(locs_Qwave,price_withTrend(locs_Qwave),'rs','MarkerFaceColor','g')
    %  plot(locs_lilQwave,price_withTrend(locs_lilQwave),'rv','MarkerFaceColor','b')


    grid on
    legend('trended Signal','R-waves','S-waves','Q-waves','lilQwave')
    xlabel('Time Samples')
    ylabel('Price')
    title('Q-waves, R-wave and S-wave in Noisy Signal')

    Anew=sortrows(locs_Qwave,1);
    Bnew=sortrows(locs_Swave,1);
    Cnew=sortrows(locs_Rwave,1);

    big_wave_array = [Anew;Bnew(:,1);Cnew(:,1)];
    big_wave_array = sortrows(big_wave_array);

    big_wave_array = unique(big_wave_array,'rows'); % RETURN %%%%%%%%%%%%%%%%%%%%%%%

    count = 0;
    deletion = zeros(length(big_wave_array),1);

    % find the duplicate values for y axis
    for i=1:length(big_wave_array)-1
         if price_withTrend(big_wave_array(i)) == price_withTrend(big_wave_array(i+1))
           deletion(i+1) = 1;
         end
    end

    % remove the duplicate values for y axis from index array

    big_wave_array(any(deletion==1,2),:)=[];

    big_linearray(1,1) = 1;

    for i = 1:length(big_wave_array)-1
        big_linearray(i+1,1) = big_wave_array(i,1);
    end

    for i = 1:length(big_wave_array) 
        big_linearray(i,2) = big_wave_array(i,1);
    end

    big_linearray(1,3) = price_withTrend(big_linearray(1,2));

    for i = 1:length(big_wave_array)
        big_linearray(i,3) = price_withTrend(big_linearray(i,2)) - price_withTrend(big_linearray(i,1));
    end

    for i = 1:length(big_wave_array) 
        big_linearray(i,4) = big_linearray(i,3)/(big_linearray(i,2)- big_linearray(i,1));
    end

    %add the number of smaller Q points to the matrix as a variance
    for k=1:length(big_linearray)
        for i =1:length(locs_lilQwave)
          if big_linearray(k,1) < locs_lilQwave(i) && big_linearray(k,2) > locs_lilQwave(i)
              count = count +1;
          end
        end
        big_linearray(k,5) = count; % RETURN %%%%%%%%%%%%%%%%%%%%%%%
        count = 0;
    end
end % END FUNC



