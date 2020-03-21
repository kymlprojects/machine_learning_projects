clear all;
close all;
clc;

load 'btc_data.mat'
load 'slopeInfoTest1.mat'

Wn = 3000; % Moving averaging window length. Default: 3000
truncPoint = 27; % Number of data point that'll be truncates from the beginning. Default:27
Mn = 4; % Half of feature vector size. Default: 4
K = 6; % Number of nearest neighbors in consideration. Default: 6
trainSize = 80; %Number of vectors that'll go into KNN algorithm. Default: 80 (heavily depends on Wn)

%Plot unprocessed price chart
tmonthly=t/(28*24*60);
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

%----Normalize chart----
dummy1=sort(RSprice);
dummy2=sort(RSt);
RSt=(dummy1(end)-dummy1(1))*(RSt/(dummy2(end)-dummy2(1)));
%-----------------------

%Find slopes of price movements
RSpricediff=diff(RSprice);
RStdiff=diff(RSt);
slopes=RSpricediff./RStdiff;

% Create feature space
featureVectors=zeros(length(RSprice)-Mn-1,2*Mn);
outputs=zeros(length(RSprice)-Mn-1,1);
nextPrices=outputs;

for k=1:length(RSprice)-Mn-1
    featureVectors(k,1:Mn)=RSpricediff(k:k+Mn-1);
    featureVectors(k,Mn+1:2*Mn)=RStdiff(k:k+Mn-1);
    outputs(k)=RStdiff(k+Mn);
    nextPrices(k)=RSpricediff(k+Mn);
end
testOutputs=zeros(length(outputs)-trainSize,1);
testPredictions=testOutputs;
testPrices=testOutputs;
for k=trainSize+1:length(outputs)
    
    input=featureVectors(k,:);
    output=outputs(k);
    distances=zeros(trainSize,1);

    for l=1:trainSize
        distances(l)=norm(input-featureVectors(l,:));
    end

    [sortedDistances, sortedIndices] = sort(distances);
    nearests = distances(sortedIndices(1:K));

    Ki = exp(-nearests.^2/2)/(2*pi);
    wi=Ki./sum(Ki);

    testPredictions(k-trainSize)=sum(wi.*outputs(sortedIndices(1:K)));
    testOutputs(k-trainSize)=output;
    testPrices(k-trainSize)=nextPrices(k);
    %pangle=atan(prediction)*180/pi
    %oangle=atan(output)*180/pi

end
figure; stem(testPredictions,'o'); hold on; stem(testOutputs,'o');
legend('Predicted durations', 'Real durations');
title('Duration prediction comparision');
xlabel('Experiment count');
ylabel('Duration');

pricePredictions=slopePredictions.*testPredictions;
figure; stem(pricePredictions,'o'); hold on; stem(testPrices,'o');




