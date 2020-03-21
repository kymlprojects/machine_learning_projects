load('recent_btc_price.mat')% load the data to the workspace

     Am = table2array(Untitled);% create table from the price data
     xv = Am(:,2);% get only the closing prices
     plot(xv) 
      
    btcdata = readtable('newa.xlsx');% 
    price = cellfun(@str2double,btcdata{:,1});
    price_withTrend = price(1:end);
    price_withTrend = [price_withTrend; xv];
    t = 1:length(price_withTrend);

    % plot the the signals with curve
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
    % begginnig time
    for i = 1:length(big_wave_array)-1
        big_linearray(i+1,1) = big_wave_array(i,1);
    end
    %end time
    for i = 1:length(big_wave_array) 
        big_linearray(i,2) = big_wave_array(i,1);
    end
    
    big_linearray(1,3) = price_withTrend(big_linearray(1,2));
    %duration
    for i = 1:length(big_wave_array)
        big_linearray(i,3) = price_withTrend(big_linearray(i,2)) - price_withTrend(big_linearray(i,1));
    end
    %slope of magnitude and duration
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
    
    
    
%%%%%%%%%%%%%%%%%%%% regression tree %%%%%%%%%%%%%%%%%%%% 
indice = 19100;
num = 0;
goback = 5;
win_percentage1 = 0;
%Find the index of the linear lines starting just before the desired time
%point
[c, index] = min(abs(big_linearray(:,2)-indice));
if c <big_linearray(index,2)
    num = index+1;
end

knn_array = big_linearray(num-goback+1:num,:); %save the last "goback" number of lines in an array


for i=4:length(big_linearray)

    
    categorical(i-3,1) = big_linearray(i-1,3);%magnitude
    categorical(i-3,2) = big_linearray(i-1,2)-big_linearray(i-1,1) ;%duration
    categorical(i-3,3) = big_linearray(i-1,5);

    categorical(i-3,4) = big_linearray(i-2,3);%magnitude
    categorical(i-3,5) = big_linearray(i-2,2)-big_linearray(i-2,1) ;%duration
    categorical(i-3,6) = big_linearray(i-2,5);

    categorical(i-3,7) = big_linearray(i-3,3);%magnitude
    categorical(i-3,8) = big_linearray(i-3,2)-big_linearray(i-3,1) ;%duration
    categorical(i-3,9) = big_linearray(i-3,5);

    categorical(i-3,10) = big_linearray(i,3);%magnitude
    categorical(i-3,11) = big_linearray(i,2)-big_linearray(i,1) ;%duration
    categorical(i-3,12) = big_linearray(i,5);
 
 

end

%%%%%%% create regression tree for duration
categorical = categorical(any(categorical,2),:);
magnitude_categorical = categorical(:,11);

categorical1 = categorical(:,1:9);

recategorical = [categorical1 magnitude_categorical];
tree = fitrtree(categorical1,magnitude_categorical,'MaxNumSplits',44,'CrossVal','on');
view(tree.Trained{1},'Mode','graph');
%%%%%%%


% include values from the given index for regression magnitude, duration
% and variance
my_values_array5 = [knn_array(5,3) knn_array(5,2) - knn_array(5,1) knn_array(5,5) ];
my_values_array4 = [knn_array(4,3) knn_array(4,2) - knn_array(4,1) knn_array(4,5) ];
my_values_array3 = [knn_array(3,3) knn_array(3,2) - knn_array(3,1) knn_array(3,5) ];
my_values_array2 = [knn_array(2,3) knn_array(2,2) - knn_array(2,1) knn_array(2,5) ];
my_values_array1 = [knn_array(1,3) knn_array(1,2) - knn_array(1,1) knn_array(1,5) ];

% add these values to a single matrix
my_values= [my_values_array3 my_values_array2 my_values_array1 my_values_array4 ];

% get the calculated values from the tree
node_error = tree.Trained{1}.NodeError; % node errors in the regression tree
node_mean = tree.Trained{1}.NodeMean; % meanof every node
node_prob = tree.Trained{1}.NodeProbability;
parenthood = tree.Trained{1}.Parent;
cut_predictor = tree.Trained{1}.CutPredictor;
cut_point = tree.Trained{1}.CutPoint;
num_of_nodes = tree.Trained{1}.NumNodes;
tree_children = tree.Trained{1}.Children;
new_cut_predictor = zeros(length(cut_predictor),1);

for i = 1:length(cut_predictor)
    if strcmpi(cut_predictor{i,1},'x1') 
        new_cut_predictor(i,1) = 1;
    end
    if strcmpi(cut_predictor{i,1},'x2') 
        new_cut_predictor(i,1) = 2;
    end
    if strcmpi(cut_predictor{i,1},'x3') 
        new_cut_predictor(i,1) = 3;
    end
    if strcmpi(cut_predictor{i,1},'x4') 
        new_cut_predictor(i,1) = 4;
    end
    if strcmpi(cut_predictor{i,1},'x5') 
        new_cut_predictor(i,1) = 5;
    end
    if strcmpi(cut_predictor{i,1},'x6') 
        new_cut_predictor(i,1) = 6;
    end
    if strcmpi(cut_predictor{i,1},'x7') 
        new_cut_predictor(i,1) = 7;
    end
    if strcmpi(cut_predictor{i,1},'x8') 
        new_cut_predictor(i,1) = 8;
    end
    if strcmpi(cut_predictor{i,1},'x9') 
        new_cut_predictor(i,1) = 9;
    end
    

end
next_node = 1;
stop = 0;
node_info = {};
add_matrix = [next_node node_error(next_node) node_mean(next_node) node_prob(next_node)];
node_info =[node_info add_matrix] ;

nan_values = isnan(cut_point);
while stop == 0
             
          if  nan_values(next_node) == 1
                stop = 1;
          end
            
          if(new_cut_predictor(next_node) ~= 0)
                if  my_values(1,new_cut_predictor(next_node)) < cut_point(next_node)
                    next_node = tree_children(next_node,1);
                    add_matrix = [next_node node_error(next_node) node_mean(next_node) node_prob(next_node)];
                    node_info =[node_info add_matrix] ;
            
            
                elseif my_values(1,new_cut_predictor(next_node)) >= cut_point(next_node)
                    next_node = tree_children(next_node,2);
                    add_matrix = [next_node node_error(next_node) node_mean(next_node) node_prob(next_node)];
                    node_info =[node_info add_matrix] ;
            
            
            
                end
    
          end
   
end


while halt == 0
    
    
if  nan_values2(next_node2) == 1
                halt = 1;
          end
            
          if(new_cut_predictor2(next_node2) ~= 0)
                if  my_values(1,new_cut_predictor2(next_node2)) < cut_point2(next_node2)
                    next_node2 = tree_children2(next_node2,1);
                    add_matrix2 = [next_node2 node_error2(next_node2) node_mean2(next_node2) node_prob2(next_node2)];
                    node_info2 =[node_info2 add_matrix2] ;
            
            
                elseif my_values(1,new_cut_predictor2(next_node2)) >= cut_point2(next_node2)
                    next_node2 = tree_children2(next_node2,2);
                    add_matrix2 = [next_node2 node_error2(next_node2) node_mean2(next_node2) node_prob2(next_node2)];
                    node_info2 =[node_info2 add_matrix2] ;
                    
            
            
                end
    
          end


end


















% for n=1:length(node_info)-1
% efficiency1 = node_info(1,n);
% efficiency1 = cell2mat(efficiency1);
% efficiency2 = node_info(1,n+1);
% efficiency2 = cell2mat(efficiency2);
% 
% 
% eff(n,1) =  efficiency2(1,2) - efficiency1(1,2) ;
% eff(n,2) = (2.^n)*efficiency2(1,2);
% eff(n,3) = (2.^n);
% eff(n,4) =  (2.^n)* efficiency1(1,4);
% 
% end
% 
% neff = eff(:,1);
% neff1 = eff(end,1);
% neff12 = sum(neff);
% neff2 = eff(end,2);
% neff3 = neff12*eff(end,3);
% neff4 = eff(n,4);
% neff5 = eff(n,3);
% 
% 
% win_percentage = 0;
% not_lose_percentage =0;
% earning = 0;
% estimation_time = node_info(1,end);
% estimation_time = cell2mat(estimation_time);
% guess = estimation_time(1,3);
% durr = 0;
% my_break = knn_array(4,1) + guess;
% durr = abs(my_break - indice);
% if(knn_array(4,3) > 0)
%     if my_break <= knn_array(4,2)
%         win_percentage =  guess/ (knn_array(4,2) -  knn_array(4,1));
%     elseif my_break > knn_array(4,2)
%         if ((knn_array(4,2) -  knn_array(4,1)) - (my_break - knn_array(4,2))) / (knn_array(4,2) -  knn_array(4,1)) > 0.66
%             win_percentage = ((knn_array(4,2) -  knn_array(4,1)) - (my_break - knn_array(4,2))) / (knn_array(4,2) -  knn_array(4,1));
%         else
%             win_percentage = 0;
%         end
%     end
% end
% 
% if(knn_array(4,3) < 0)
%     if my_break <= knn_array(4,2)
%         not_lose_percentage =  guess/ (knn_array(4,2) -  knn_array(4,1));
%     elseif my_break > knn_array(4,2)
%         not_lose_percentage =  0;
% 
%     end
% end
% 
% 
% 
% 
% earn_time = guess;
% beginning = knn_array(4,1);
% endd = knn_array(4,2);
% 
%  if knn_array(4,3) > 0
%     earning = abs(knn_array(4,4))*(my_break - indice);
% 
%  end
