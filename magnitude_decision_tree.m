%%%%%%%create regression tree for magnitude
magnitude_categorical1 = categorical(:,10);
tree2 = fitrtree(categorical1,magnitude_categorical1,'MaxNumSplits',342,'CrossVal','on');
view(tree2.Trained{1},'Mode','graph');

node_error2 = tree2.Trained{1}.NodeError;
node_mean2 = tree2.Trained{1}.NodeMean;
node_prob2 = tree2.Trained{1}.NodeProbability;
parenthood2 = tree2.Trained{1}.Parent;
cut_predictor2 = tree2.Trained{1}.CutPredictor;
cut_point2 = tree2.Trained{1}.CutPoint;
num_of_nodes2 = tree2.Trained{1}.NumNodes;
tree_children2 = tree2.Trained{1}.Children;
new_cut_predictor2 = zeros(length(cut_predictor2),1);

for i = 1:length(cut_predictor2)
    if strcmpi(cut_predictor2{i,1},'x1') 
        new_cut_predictor2(i,1) = 1;
    end
    if strcmpi(cut_predictor2{i,1},'x2') 
        new_cut_predictor2(i,1) = 2;
    end
    if strcmpi(cut_predictor2{i,1},'x3') 
        new_cut_predictor2(i,1) = 3;
    end
    if strcmpi(cut_predictor2{i,1},'x4') 
        new_cut_predictor2(i,1) = 4;
    end
    if strcmpi(cut_predictor2{i,1},'x5') 
        new_cut_predictor2(i,1) = 5;
    end
    if strcmpi(cut_predictor2{i,1},'x6') 
        new_cut_predictor2(i,1) = 6;
    end
    if strcmpi(cut_predictor2{i,1},'x7') 
        new_cut_predictor2(i,1) = 7;
    end
    if strcmpi(cut_predictor2{i,1},'x8') 
        new_cut_predictor2(i,1) = 8;
    end
    if strcmpi(cut_predictor2{i,1},'x9') 
        new_cut_predictor2(i,1) = 9;
    end
    

end
next_node2 = 1;
stop2 = 0;
node_info2 = {};
add_matrix2 = [next_node2 node_error2(next_node2) node_mean2(next_node2) node_prob2(next_node2)];
node_info2 =[node_info2 add_matrix2] ;

nan_values2 = isnan(cut_point2);
while stop2 == 0
             
          if  nan_values2(next_node2) == 1
                stop2 = 1;
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

while x == 0
    
    if nanvalues2(cut_point2);
        me = getback.(btc_price);
    
    else
    
    
    
    end
    
    




