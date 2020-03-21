 function [my_break,neff5,neff4,neff3,neff2,neff1,node_prob,tree,eff,earn_time, beginning,win_percentage, endd, guess, earning,not_lose_percentage,durr] =  dataprj_2(indice, big_linearray, big_wave_array)


%indice = 19100;
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

%tree = fitrtree(categorical1,magnitude_categorical);
tree = fitrtree(categorical1,magnitude_categorical,'MaxNumSplits',44,'CrossVal','on');

%%%%%%%

% magnitude_categorical1 = categorical(:,10);
% tree2 = fitrtree(categorical1,magnitude_categorical1) 


my_values_array5 = [knn_array(5,3) knn_array(5,2) - knn_array(5,1) knn_array(5,5) ];
my_values_array4 = [knn_array(4,3) knn_array(4,2) - knn_array(4,1) knn_array(4,5) ];
my_values_array3 = [knn_array(3,3) knn_array(3,2) - knn_array(3,1) knn_array(3,5) ];
my_values_array2 = [knn_array(2,3) knn_array(2,2) - knn_array(2,1) knn_array(2,5) ];
my_values_array1 = [knn_array(1,3) knn_array(1,2) - knn_array(1,1) knn_array(1,5) ];

my_values= [my_values_array3 my_values_array2 my_values_array1 my_values_array4 ];
% my_values.Properties.VariableNames = {'x1' 'x2' 'x3' 'x4' 'x5' 'x6' 'x7' 'x8' 'x9'};
node_error = tree.Trained{1}.NodeError;
node_mean = tree.Trained{1}.NodeMean;
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

for n=1:length(node_info)-1
efficiency1 = node_info(1,n);
efficiency1 = cell2mat(efficiency1);
efficiency2 = node_info(1,n+1);
efficiency2 = cell2mat(efficiency2);


eff(n,1) =  efficiency2(1,2) - efficiency1(1,2) ;
eff(n,2) = (2.^n)*efficiency2(1,2);
eff(n,3) = (2.^n);
eff(n,4) =  (2.^n)* efficiency1(1,4);

end

neff = eff(:,1);
neff1 = eff(end,1);
neff12 = sum(neff);
neff2 = eff(end,2);
neff3 = neff12*eff(end,3);
neff4 = eff(n,4);
neff5 = eff(n,3);
% last_count = 0;
% if length(eff) > 1
%     for i =1: length(eff)-1
%         if eff(i,1) <= eff(i+1,1)
%             last_count = last_count + 1;
%     end
% 
% end
% end
win_percentage = 0;
not_lose_percentage =0;
earning = 0;
estimation_time = node_info(1,end);
estimation_time = cell2mat(estimation_time);
guess = estimation_time(1,3);
durr = 0;
my_break = knn_array(4,1) + guess;
durr = abs(my_break - indice);
if(knn_array(4,3) > 0)
    if my_break <= knn_array(4,2)
        win_percentage =  guess/ (knn_array(4,2) -  knn_array(4,1));
    elseif my_break > knn_array(4,2)
        if ((knn_array(4,2) -  knn_array(4,1)) - (my_break - knn_array(4,2))) / (knn_array(4,2) -  knn_array(4,1)) > 0.66
            win_percentage = ((knn_array(4,2) -  knn_array(4,1)) - (my_break - knn_array(4,2))) / (knn_array(4,2) -  knn_array(4,1));
        else
            win_percentage = 0;
        end
    end
end

if(knn_array(4,3) < 0)
    if my_break <= knn_array(4,2)
        not_lose_percentage =  guess/ (knn_array(4,2) -  knn_array(4,1));
    elseif my_break > knn_array(4,2)
        not_lose_percentage =  0;

    end
end




earn_time = guess;
beginning = knn_array(4,1);
endd = knn_array(4,2);

 if knn_array(4,3) > 0
    earning = abs(knn_array(4,4))*(my_break - indice);

 end
 end