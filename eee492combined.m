clear all;
close all;
clc;

load 'btc_data.mat' %Has price and time in minutes

SLOPE_PREDICTION=1; %Set to 1 to turn on next slope prediction
TIME_PREDICTION=1; %Set to 1 to turn on next duration prediction

Wn = 3000; % Moving averaging window length. Default: 3000
truncPoint = 27; % Number of data point that'll be truncates from the beginning. Default:27
Mn = 4; % Feature vector size (Half size for time prediction). Default: 4
K = 6; % Number of nearest neighbors in consideration. Default: 6
trainSize = 80; %Number of vectors that'll go into KNN algorithm. Default: 80 (heavily depends on Wn)

%Plot unprocessed price chart
tmonthly=t/(28*24*60); %Time in months
figure; plot(tmonthly,price);
title('Unprocessed Bitcoin Price Chart');
xlabel('Months');
ylabel('$');
grid on;

%Average and plot chart
priceav=movmean(price,Wn);
figure; plot(tmonthly,priceav);
title('Moving Averaged Price Chart');
xlabel('Months');
ylabel('$');
grid on;

% Find QRS peaks on averaged chart
[~,locs_Rwave] = findpeaks(priceav,'MinPeakProminence',3);
[~,locs_Swave] = findpeaks(-priceav,'MinPeakProminence',3);
[~,locs_Qwave] = findpeaks(-priceav,'MinPeakProminence',1);

% Combine R and S peaks
locs_RS = sort([locs_Rwave; locs_Swave]);
price_RS = priceav(locs_RS);
% Show on chart
figure; plot(locs_RS,price_RS); hold on;
plot(locs_Rwave,priceav(locs_Rwave),'rv','MarkerFaceColor','r');
plot(locs_Swave,priceav(locs_Swave),'rs','MarkerFaceColor','b');
legend('Btc price','R-peaks','S-peaks');
title('Averaged Price Chart with RS peaks');
xlabel('Months');
ylabel('$');
grid on;



% K-Nearest Neighbors
% Truncate the price chart
RSprice=price_RS(truncPoint:end);
RSt=t(locs_RS(truncPoint:end));
figure; plot(RSt,RSprice);
title('Truncated Price Chart');
xlabel('minutes');
ylabel('$');

%----Normalize chart--------------------------------------
dummy1=sort(RSprice);
dummy2=sort(RSt);
RSt=(dummy1(end)-dummy1(1))*(RSt/(dummy2(end)-dummy2(1)));
%---------------------------------------------------------

%Find price and time differences
RSpricediff=diff(RSprice);
RStdiff=diff(RSt);

%Slope prediction
if SLOPE_PREDICTION==1 
    slopes=RSpricediff./RStdiff; %Find slopes of price movements
    %Create slope feature space/vectors
    sFeatureVectors=zeros(length(RSprice)-Mn-1,Mn);
    sOutputs=zeros(length(RSprice)-Mn-1,1);
    %Combine vectors in a matrix
    for k=1:length(RSprice)-Mn-1
        sFeatureVectors(k,:)=slopes(k:k+Mn-1);
        sOutputs(k)=slopes(k+Mn);
    end
    %Allocate prediction and real value matrices
    slopeOutputs=zeros(length(sOutputs)-trainSize,1);
    slopePredictions=slopeOutputs;
    
    % Experiment with test vectors
    for k=trainSize+1:length(sOutputs)
        
        %Get the sample
        input=sFeatureVectors(k,:);
        output=sOutputs(k);
        
        %Find euclidian distances
        distances=zeros(trainSize,1);
        for l=1:trainSize
            distances(l)=norm(input-sFeatureVectors(l,:));
        end
        
        %Find nearest neighbors
        [sortedDistances, sortedIndices] = sort(distances);
        nearests = distances(sortedIndices(1:K));
        
        nvar=var(nearests); %Variance of k-nearest neighbors' distance from the input
        %Find weights for weighted summation
        Ki = exp(-nearests.^2/(2*nvar)/sqrt(2*pi*nvar));
        wi=Ki./sum(Ki);
        
        %Prediction
        slopePredictions(k-trainSize)=sum(wi.*sOutputs(sortedIndices(1:K)));
        slopeOutputs(k-trainSize)=output;
        
    end
    figure; stem(slopePredictions,'o'); hold on; stem(slopeOutputs,'o');
    legend('Predicted slopes', 'Real slopes');
    title('Slope prediction comparision');
    xlabel('Experiment count');
    ylabel('Slope');
end


%Next duration (time) prediction
if TIME_PREDICTION==1
    % Create time&magnitude feature space/vectors
    tFeatureVectors=zeros(length(RSprice)-Mn-1,2*Mn);
    tOutputs=zeros(length(RSprice)-Mn-1,1);
    nextPrices=tOutputs;
    for k=1:length(RSprice)-Mn-1
        tFeatureVectors(k,1:Mn)=RSpricediff(k:k+Mn-1);
        tFeatureVectors(k,Mn+1:2*Mn)=RStdiff(k:k+Mn-1);
        tOutputs(k)=RStdiff(k+Mn);
        nextPrices(k)=RSpricediff(k+Mn);
    end
    %Allocate prediction and real value matrices
    timeOutputs=zeros(length(tOutputs)-trainSize,1);
    timePredictions=timeOutputs;
    realPrices=timeOutputs;
    
    % Experiment with test vectors
    for k=trainSize+1:length(tOutputs)
    
        input=tFeatureVectors(k,:);
        output=tOutputs(k);
        distances=zeros(trainSize,1);
        
        %Find Euclidian Distances
        for l=1:trainSize
            distances(l)=norm(input-tFeatureVectors(l,:));
        end
        
        %Find nearest neighbors
        [sortedDistances, sortedIndices] = sort(distances);
        nearests = distances(sortedIndices(1:K));
        
        nvar=var(nearests); %Variance of k-nearest neighbors' distance from the input
        %Find weights for weighted summation
        Ki = exp(-nearests.^2/(2*nvar)/sqrt(2*pi*nvar));
        wi=Ki./sum(Ki);
        
        %Prediction
        timePredictions(k-trainSize)=sum(wi.*tOutputs(sortedIndices(1:K)));
        timeOutputs(k-trainSize)=output;
        realPrices(k-trainSize)=nextPrices(k);
        %pangle=atan(prediction)*180/pi
        %oangle=atan(output)*180/pi

    end
    figure; stem(timePredictions,'o'); hold on; stem(timeOutputs,'o');
    legend('Predicted durations', 'Real durations');
    title('Duration prediction comparision');
    xlabel('Experiment count');
    ylabel('Duration'); 
end

% Predict magnitude of nex price movement by multiplying predicted slope
% and duration
if ((SLOPE_PREDICTION==1)&&(TIME_PREDICTION==1))
    pricePredictions=slopePredictions.*timePredictions;
    figure; stem(pricePredictions,'o'); hold on; stem(realPrices,'o');
    legend('Predicted prices', 'Real prices');
    title('Price prediction comparision');
    xlabel('Experiment count');
    ylabel('Duration'); 
end














