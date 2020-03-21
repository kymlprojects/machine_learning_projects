% Main

clc;
clear all;
close all;

% Piece
money = 0;
k = 0;
k1 = 0;
k2 = 0;

duratio = 0;
mean_increase = 0;
mean_decrease = 0;
big_mean_increase = 0;
[big_linearray, big_wave_array] =  piecewise_linear_regression();
time = 24*60;
indexes = zeros(1,time);
wins =zeros(1,length(indexes));
offset = 10000;
for i=1 : time
indexes(i) =210*i;
end
% new_indexes=[5000 12000 15000 7000 3400 8000 9000 17000];

indexes = indexes + offset;
% Apply Reg Tree
for i=1:length(indexes)
% [earn_time, beginning,win_percentage, endd, guess, earning,not_lose_percentage,durr] =  the_last_trial(indexes(i), big_linearray,big_wave_array);
[my_break,neff5,neff4,neff3,neff2,neff1,node_prob,tree,eff,earn_time, beginning,win_percentage, endd, guess, earning,not_lose_percentage,durr] =  dataprj_2(indexes(i), big_linearray, big_wave_array);
money = money + earning;
wins(1,i) = win_percentage;
% prob(i) = node_prob;
wins1(1,i) = neff1;
wins2(1,i) = neff2;
wins3(1,i) = neff3;
wins4(1,i) = neff4;
wins5(1,i) = neff5;
wins6(1,i) = guess;
notlose(i) =not_lose_percentage;
duratio = duratio + durr;
end



wins4(1,i) = neff4;
wins5(1,i) = neff5;



% Test
for i = 1:length(wins)-1
    if wins(i) ~= 0
        if wins(i) ~=wins(i+1)
            mean_increase = mean_increase + wins(i) ;
            k = k + 1;

            if wins(i) >= 0.75
                big_mean_increase = big_mean_increase + wins(i);
                k2 = k2 + 1;
            end
        end
    end
end

% mean of accuracy of increasing values

mean_increase = mean_increase /k;

for i = 1:length(notlose)-1
    if notlose(i) ~= 0
                if notlose(i) ~= notlose(i+1)

                     mean_decrease = mean_decrease + notlose(i) ;
                     k1 = k1 + 1;
                end
    end
end


% mean of accuracy of decreasing values
mean_decrease = mean_decrease /k1;

% earning rate per minute
earning_rate = money / duratio;

big_mean_increase_ratio =  k2 / k;
wins = [wins ; wins2;wins1;wins3;wins4;wins5;wins6];
% win_mean =mean(wins);

for i = 1:100

   better = wins/win;
   
    
end