function [earn_time, beginning,win_percentage, endd, guess, earning,not_lose_percentage,durr] =  the_last_trial(indice, big_linearray, big_wave_array)


% indice = 17900;
num = 0;
goback = 5;

%Find the index of the linear lines starting just before the desired time
%point
[c, index] = min(abs(big_linearray(:,2)-indice));
if c <big_linearray(index,2)
    num = index+1;
end

knn_array = big_linearray(num-goback+1:num,:); %save the last "goback" number of lines in an array
% searchdegree = zeros(length(knn_array),2); % create an array to put degree intervals of the values
searchmagnitude = zeros(length(knn_array),2); % create an array to put degree intervals of the values

% find the interval of search for every line.
for i=1:length(knn_array)
    if knn_array(i,3)>0
searchmagnitude(i,1) = knn_array(i,3)*3/5;
searchmagnitude(i,2) = knn_array(i,3)*6/5;
    elseif knn_array(i,3)<0
searchmagnitude(i,2) = knn_array(i,3)*3/5;
searchmagnitude(i,1) = knn_array(i,3)*6/5;  
    end
end

knn_array =[knn_array searchmagnitude];% add the interval of search to the next column of every line
new_knn_array= zeros(length(big_linearray),goback);
indice_array = zeros(length(big_linearray),1);

% find the lines with the magnitude between the given values closest to the
% target 

for z=1:length(big_linearray)
     
    if  big_linearray(z ,3) <= knn_array(goback,7) &&  big_linearray(z,3) >=  knn_array(goback,6)
        new_knn_array(z,1) = 1;
         
    end
    
    
end


for z=2:length(big_linearray)+1
%    if new_knn_array(z-1,1) == 1
    if big_linearray(z-1,3)<= knn_array(goback-1,7) &&  big_linearray(z-1,3) >= knn_array(goback-1,6)
        new_knn_array(z,2) = 1;
         
     end
%    end
end


for z=3:length(big_linearray)+2
%    if new_knn_array(z-1,1) == 1
    if big_linearray(z-2,3)<= knn_array(goback-2,7) &&  big_linearray(z-2,3) >= knn_array(goback-2,6)
        new_knn_array(z,3) = 1;
         
     end
%    end
end


for z=4:length(big_linearray)+3
%    if new_knn_array(z-1,1) == 1
    if big_linearray(z-3,3)<= knn_array(goback-3,7) &&  big_linearray(z-3,3) >= knn_array(goback-3,6)
        new_knn_array(z,4) = 1;
         
     end
%    end
end

for z=5:length(big_linearray)+4
%    if new_knn_array(z-1,1) == 1
    if big_linearray(z-4,3)<= knn_array(goback-4,7) &&  big_linearray(z-4,3) >= knn_array(goback-4,6)
        new_knn_array(z,5) = 1;
         
     end
%    end
end
 
%%% knn classfier

%% eulidian distance
count = 0;
newcount = 1;


for i =1:length(new_knn_array)
        if new_knn_array(i,1) == new_knn_array(i,2) && new_knn_array(i,1) ==1
        count =2;
        if new_knn_array(i,2) == new_knn_array(i,3)&& new_knn_array(i,2) ==1
        count =3;
        if new_knn_array(i,3) == new_knn_array(i,4)&& new_knn_array(i,3) ==1
        count =4;
        if new_knn_array(i,4) == new_knn_array(i,5)&& new_knn_array(i,4) ==1
        count =5;
        end
        end
        end
    
        end
    countarray(i) = count;
    count = 0;
end

for i=1:length(big_linearray)
 if countarray(i) >3

    
    categorical(i,1) = big_linearray(i-1,3);%magnitude
    categorical(i,2) = big_linearray(i-1,2)-big_linearray(i-1,1) ;%duration
    categorical(i,3) = big_linearray(i-1,5);

    categorical(i,4) = big_linearray(i-2,3);%magnitude
    categorical(i,5) = big_linearray(i-2,2)-big_linearray(i-2,1) ;%duration
    categorical(i,6) = big_linearray(i-2,5);

    categorical(i,7) = big_linearray(i-3,3);%magnitude
    categorical(i,8) = big_linearray(i-3,2)-big_linearray(i-3,1) ;%duration
    categorical(i,9) = big_linearray(i-3,5);

    categorical(i,10) = big_linearray(i,3);%magnitude
    categorical(i,11) = big_linearray(i,2)-big_linearray(i,1) ;%duration
    categorical(i,12) = big_linearray(i,5);
 
 
 end
end
% categorical= normc(categorical);

categorical = categorical(any(categorical,2),:);
magnitude_categorical = categorical(:,11);

categorical1 = categorical(:,1:9);

recategorical = [categorical1 magnitude_categorical];
tree = fitrtree(categorical1,magnitude_categorical);
 

my_values_array5 = [knn_array(5,3) knn_array(5,2) - knn_array(5,1) knn_array(5,5) ];

my_values_array4 = [knn_array(4,3) knn_array(4,2) - knn_array(4,1) knn_array(4,5) ];
my_values_array3 = [knn_array(3,3) knn_array(3,2) - knn_array(3,1) knn_array(3,5) ];
my_values_array2 = [knn_array(2,3) knn_array(2,2) - knn_array(2,1) knn_array(2,5) ];
my_values_array1 = [knn_array(1,3) knn_array(1,2) - knn_array(1,1) knn_array(1,5) ];

my_values= [my_values_array4 my_values_array3 my_values_array2 my_values_array1 ];
% my_values.Properties.VariableNames = {'x1' 'x2' 'x3' 'x4' 'x5' 'x6' 'x7' 'x8' 'x9'};
node_error = tree.NodeError;
node_mean = tree.NodeMean;
node_prob = tree.NodeProbability;
parenthood = tree.Parent;
cut_predictor = tree.CutPredictor;
cut_point = tree.CutPoint;
num_of_nodes = tree.NumNodes;
tree_children = tree.Children;
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
            
            
                elseif my_values(1,new_cut_predictor(next_node)) > cut_point(next_node)
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

eff(n,1) = efficiency2(1,2) - efficiency1(1,2);
eff(n,2) = n;
end


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
my_break = knn_array(5,1) + guess;
durr = abs(my_break - indice);
if(knn_array(5,3) > 0)
    if my_break <= knn_array(5,2)
        win_percentage =  guess/ (knn_array(5,2) -  knn_array(5,1));
    elseif my_break > knn_array(5,2)
        if my_break - knn_array(5,2) / (knn_array(5,2) -  knn_array(5,1)) < 0.66
            win_percentage = ((my_break - knn_array(5,2))/ (knn_array(5,2) -  knn_array(5,1)));
        else
            win_percentage = 0;
        end
    end
end

if(knn_array(5,3) < 0)
    if my_break <= knn_array(5,2)
        not_lose_percentage =  guess/ (knn_array(5,2) -  knn_array(5,1));
    elseif my_break > knn_array(5,2)
        not_lose_percentage =  0;

    end
end




earn_time = guess;
beginning = knn_array(5,1);
endd = knn_array(5,2);

 if knn_array(5,3) > 0
    earning = abs(knn_array(5,4))*(my_break - indice);

end
 end
