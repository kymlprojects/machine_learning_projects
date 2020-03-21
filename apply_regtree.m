function [knn_array, parenthood, error, split1, split2, bound_value, cat_size_1, cat_size_2] =  apply_regtree(indice)
    tic
    num = 0;
    goback = 5;

    %Find the index of the linear lines starting just before the desired time
    %point
    [c, index] = min(abs(big_linearray(:,2)-indice));
    if c <big_linearray(index,2)
        num = index;
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
    %     categorical(i,1) = big_linearray(i,3);%magnitude
    %     categorical(i,2) = big_linearray(i,2)-big_linearray(i,1) ;%duration
    %     categorical(i,3) = big_linearray(i,5);

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
    categorical= normc(categorical);

    categorical = categorical(any(categorical,2),:);
    magnitude_categorical = categorical(:,11);

    categorical1 = categorical(:,1:9);

    recategorical = [categorical1 magnitude_categorical];
    tree = classregtree(categorical1,magnitude_categorical);



    parenthood ={1,2,3;2,4,5;3,6,7;4,8,9;5,10,11;6,12,13;7,14,15};

    [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(recategorical);
    error(1) = error ;
    split1(1) = split_row;
    split2(1) = split_column;
    bound_value(1) = bound_value;
    cat_size_1(1) = cat_size_1;
    cat_size_2(1) = cat_size_2;
    sp1 = newcat1;
    sp2 = newcat2;

    if length(sp1) > 15

        [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1);
        error(2) = error ;
        split1(2) = split_row;
        split2(2) = split_column;
        bound_value(2) = bound_value;
        cat_size_1(2) = cat_size_1;
        cat_size_2(2) = cat_size_2;
        sp1_1 = newcat1;
        sp1_2 = newcat2;


        if length(sp1_1) > 15

            [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1_1);
            error(4) = error ;
            split1(4) = split_row;
            split2(4) = split_column;
            bound_value(4) = bound_value;
            cat_size_1(4) = cat_size_1;
            cat_size_2(4) = cat_size_2;
            sp1_1_1 = newcat1;
            sp1_1_2 = newcat2;


            if length(sp1_1_1) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1_1_1);
                error(8) = error ;
                split1(8) = split_row;
                split2(8) = split_column;
                bound_value(8) = bound_value;
                cat_size_1(8) = cat_size_1;
                cat_size_2(8) = cat_size_2;
                sp1_1_1_1 = newcat1;
                sp1_1_1_2 = newcat2;
            end

            if length(sp1_1_2) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1_1_2);
                error(9) = error ;
                split1(9) = split_row;
                split2(9) = split_column;
                bound_value(9) = bound_value;
                cat_size_1(9) = cat_size_1;
                cat_size_2(9) = cat_size_2;
                sp1_1_2_1 = newcat1;
                sp1_1_2_2 = newcat2;
            end

        end % SP1_1

        if length(sp1_2) > 15

            [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1_2);
            error(5) = error ;
            split1(5) = split_row;
            split2(5) = split_column;
            bound_value(5) = bound_value;
            cat_size_1(5) = cat_size_1;
            cat_size_2(5) = cat_size_2;
            sp1_2_1 = newcat1;
            sp1_2_2 = newcat2;



            if length(sp1_2_1) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1_2_1);
                error(10) = error ;
                split1(10) = split_row;
                split2(10) = split_column;
                bound_value(10) = bound_value;
                cat_size_1(10) = cat_size_1;
                cat_size_2(10) = cat_size_2;
                sp1_2_1_1 = newcat1;
                sp1_2_1_2 = newcat2;
            end 

            if length(sp1_2_2) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp1_2_2);
                error(11) = error ;
                split1(11) = split_row;
                split2(11) = split_column;
                bound_value(11) = bound_value;
                cat_size_1(11) = cat_size_1;
                cat_size_2(11) = cat_size_2;
                sp1_2_2_1 = newcat1;
                sp1_2_2_2 = newcat2;
            end

        end % SP1_2
    end % SP_1


    if length(sp2) > 15
        [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2);
        error(3) = error ;
        split1(3) = split_row;
        split2(3) = split_column;
        bound_value(3) = bound_value;
        cat_size_1(3) = cat_size_1;
        cat_size_2(3) = cat_size_2;
        sp2_1 = newcat1;
        sp2_2 = newcat2;


        if length(sp2_1) > 15

            [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2_1);
            error(6) = error ;
            split1(6) = split_row;
            split2(6) = split_column;
            bound_value(6) = bound_value;
            cat_size_1(6) = cat_size_1;
            cat_size_2(6) = cat_size_2;
            sp2_1_1 = newcat1;
            sp2_1_2 = newcat2;


            if length(sp2_1_1) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2_1_1);
                error(12) = error ;
                split1(12) = split_row;
                split2(12) = split_column;
                bound_value(12) = bound_value;
                cat_size_1(12) = cat_size_1;
                cat_size_2(12) = cat_size_2;
                sp2_1_1_1 = newcat1;
                sp2_1_1_2 = newcat2;
            end

            if length(sp2_1_2) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2_1_2);
                error(13) = error ;
                split1(13) = split_row;
                split2(13) = split_column;
                bound_value(13) = bound_value;
                cat_size_1(13) = cat_size_1;
                cat_size_2(13) = cat_size_2;
                sp2_1_2_1 = newcat1;
                sp2_1_2_2 = newcat2;
            end

        end % SP2_1

        if length(sp2_2) > 15

            [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2_2);
            error(7) = error ;
            split1(7) = split_row;
            split2(7) = split_column;
            bound_value(7) = bound_value;
            cat_size_1(7) = cat_size_1;
            cat_size_2(7) = cat_size_2;
            sp2_2_1 = newcat1;
            sp2_2_2 = newcat2;


            if length(sp2_2_1) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2_2_1);
                error(14) = error ;
                split1(14) = split_row;
                split2(14) = split_column;
                bound_value(14) = bound_value;
                cat_size_1(14) = cat_size_1;
                cat_size_2(14) = cat_size_2;
                sp2_2_1_1 = newcat1;
                sp2_2_1_2 = newcat2;
            end

            if length(sp2_2_2) > 15

                [rss, error, split_row, split_column ,newcat1 ,newcat2, bound_value, cat_size_1, cat_size_2] = regtree(sp2_2_2);
                error(15) = error ;
                split1(15) = split_row;
                split2(15) = split_column;
                bound_value(15) = bound_value;
                cat_size_1(15) = cat_size_1;
                cat_size_2(15) = cat_size_2;
                sp2_2_2_1 = newcat1;
                sp2_2_2_2 = newcat2;
            end

        end % SP2_2
    end % SP_2
end % END FUNC
