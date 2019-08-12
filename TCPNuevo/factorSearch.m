clc
clear all
%rng(3)

%Resultado de la solución del sistema de ecuaciones:
% Factor = 0.9784, Resolvido en wolframalpha.com

iterations = 100000; %Fariness Test Iterations
n = 3000; %Factor Search Iterations
factor = zeros(1,n);
factor(1) = 0.99; %best value found so far = 0.9784
probs1 = zeros(1,n);
probs2 = zeros(1,n);

for k=1:n
%New CWND Algorithm (initialization)
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

%Old TCP Algorithm (initialization)
cwnd2 = zeros(1,ceil(iterations));
cwnd2(1) = 4;

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
            decCwnd = averageCwnd.*factor(k); %0.983
            minCwnd = decCwnd;
            increment = increment/2;
            if fastStart <= 1
                cwnd(j+1) = cwnd(j) + 1;
                fastStart = fastStart + 1;
            end
            if increment <= incrementPerm
                increment = incrementPerm;
            end
            cwnd2(j+1) = cwnd2(j) + 1;
        end
        %Old TCP
        if lost2
            cwnd2(j+1) = floor(cwnd2(j)/2);
            decCwnd = decCwnd + averageCwnd/decCwnd*increment;
        end
        lost1 = 0;
        lost2 = 0;
    else
        decCwnd = decCwnd + averageCwnd/decCwnd*increment;
        cwnd2(j+1) = cwnd2(j) + 1;
    end
    
    %New TCP update
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

end
prob1 = prob1(1:i-1);
prob2 = prob2(1:i-1);
probs1(k) = mean(prob1);
probs2(k) = mean(prob2);
if factor(k) <= 0.96
    break
end
factor(k+1) = factor(k) - 1/n;
end

%PLOTS
factor = factor(1:k);
probs1 = probs1(1:k);
probs2 = probs2(1:k);
plot(factor,probs1,'xb');
hold on
plot(factor,probs2,'xm');
%Plot de curvas de ajuste
ajustex = 0.9:0.0001:0.999;
ajustey = -80.492*ajustex.^2 + 151.9*ajustex - 71.074;
ajustey2 = 96.227*ajustex.^2 - 182.6*ajustex + 87.043;
plot(ajustex,ajustey)
hold on
plot(ajustex,ajustey2,'r')
%Settings
ylim([0.3 0.7])
xlim([0.92 1.02])
xlabel('Factor')
ylabel('Probabilidad')
title('Fairness Test para distintos valores del factor de reducción')
% Curva Ajustada 1:
% y = -80.492*x^2 + 151.9*x - 71.074
% 
% Curva Ajustada 2:
% y = 96.227*x^2 - 182.6*x + 87.043