clc
clear all
hold off
%rng(3)

iterations = 10000000;
%New CWND Algorithm 1 (initialization)
cwnd = zeros(1,ceil(iterations));
cwnd(1) = 4;
decCwnd = cwnd(1);
minCwnd = cwnd(1);
maxCwnd = cwnd(1);
averageCwnd = cwnd(1);
average = [cwnd(1) zeros(1,iterations-1)];
var = 0.5; %Maximum variation before changing cwnd (50% default)
incrementIni = 1;
incrementPerm = 0.08;
increment = incrementIni;
fastStart = 0;

%New CWND Algorithm 2(initialization)
cwnd2 = zeros(1,ceil(iterations));
cwnd2(1) = 4;
decCwnd2 = cwnd2(1);
minCwnd2 = cwnd2(1);
maxCwnd2 = cwnd2(1);
averageCwnd2 = cwnd2(1);
average2 = [cwnd2(1) zeros(1,iterations-1)];
var = 0.5; %Maximum variation before changing cwnd (50% default)
incrementIni2 = 1;
incrementPerm2 = 0.08;
increment2 = incrementIni2;
fastStart2 = 0;

%fairness variables
ceiling = 50;
prob1 = zeros(1,ceil(iterations));
prob2 = zeros(1,ceil(iterations));
i = 1;
lost1 = 0;
lost2 = 0;
for j=1:iterations-1
    if cwnd(j) + cwnd2(j) >= ceiling
        x = rand;
        prob1(i) = cwnd(j)/(cwnd(j) + cwnd2(j));
        prob2(i) = cwnd2(j)/(cwnd(j) + cwnd2(j));
        if x <= prob1(i)
            lost1 = 1;
        else
            lost2 = 1;
        end
        i = i + 1;
        %New TCP
        if lost1
            maxCwnd = decCwnd;
            averageCwnd = abs(maxCwnd+minCwnd)/2;
            decCwnd = averageCwnd*0.97746; 
            minCwnd = decCwnd;
            increment = increment/2;
            if fastStart <= 1
                cwnd(j+1) = cwnd(j) + 1;
                fastStart = fastStart + 1;
            end
            if increment <= incrementPerm
                increment = incrementPerm;
            end
            decCwnd2 = decCwnd2 + averageCwnd2/decCwnd2*increment2;
        end
        %Old TCP
        if lost2
            maxCwnd2 = decCwnd2;
            averageCwnd2 = abs(maxCwnd2+minCwnd2)/2;
            decCwnd2 = averageCwnd2*0.97746; 
            minCwnd2 = decCwnd2;
            increment2 = increment2/2;
            if fastStart2 <= 1
                cwnd2(j+1) = cwnd2(j) + 1;
                fastStart2 = fastStart2 + 1;
            end
            if increment2 <= incrementPerm2
                increment2 = incrementPerm2;
            end
            decCwnd = decCwnd + averageCwnd/decCwnd*increment;
        end
        lost1 = 0;
        lost2 = 0;
    else
        decCwnd = decCwnd + averageCwnd/decCwnd*increment;
        decCwnd2 = decCwnd2 + averageCwnd2/decCwnd2*increment2;
    end
    
    %New TCP update 1
    if fastStart <= 1 && lost1 == 0
        cwnd(j+1) = cwnd(j) + 1;
    end
    if (decCwnd-cwnd(j))/cwnd(j) >= var 
        cwnd(j+1) = cwnd(j) + 1 ;
    elseif (decCwnd-cwnd(j))/cwnd(j) <= -var
        cwnd(j+1) = cwnd(j) - 1;
    
    else
        cwnd(j+1) = cwnd(j);
    end
    
    %New TCP update 2
    if fastStart2 <= 1 && lost2 == 0
        cwnd2(j+1) = cwnd2(j) + 1;
    end
    if (decCwnd2-cwnd2(j))/cwnd2(j) >= var 
        cwnd2(j+1) = cwnd2(j) + 1 ;
    elseif (decCwnd2-cwnd2(j))/cwnd2(j) <= -var
        cwnd2(j+1) = cwnd2(j) - 1;
    
    else
        cwnd2(j+1) = cwnd2(j);
    end

end

%disp(['promedio de ventana: ' , num2str(mean(cwnd))]);
prob1 = prob1(1:i-1);
prob2 = prob2(1:i-1);

%Plots
plot(1:length(prob2),prob2,'r');
ylim([0 1])
hold on
plot(1:length(prob1),prob1, 'b');

disp(['New TCP - Average Probability  = ', num2str(mean(prob1)*100), '%']);
disp(['Old TCP - Average Probability = ' , num2str(mean(prob2)*100), '%']);

% figure
% plot(prob1, prob2, 'xb')
% hold on
% plot(1:max(prob1, prob2), 1:max(prob1, prob2), '--k')

figure
diff = prob1 - prob2;
hist(diff,16)
xlim([-0.5 0.5])


