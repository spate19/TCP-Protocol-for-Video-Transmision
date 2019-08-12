clc
clear all
hold off
%rng(3)

iterations = 10000000;
%Old TCP Algorithm 1(initialization)
cwnd = zeros(1,ceil(iterations));
cwnd(1) = 4;
%Old TCP Algorithm 2(initialization)
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
        %Old TCP 1
        if lost1
            cwnd(j+1) = floor(cwnd(j)/2);
            cwnd2(j+1) = cwnd2(j) + 1;
        end
        %Old TCP 2
        if lost2
            cwnd2(j+1) = floor(cwnd2(j)/2);
            cwnd(j+1) = cwnd(j) + 1;
        end
        lost1 = 0;
        lost2 = 0;
    else
        cwnd(j+1) = cwnd(j) + 1;
        cwnd2(j+1) = cwnd2(j) + 1;
    end

end

%disp(['promedio de ventana: ' , num2str(mean(cwnd))]);
prob1 = prob1(1:i-1);
prob2 = prob2(1:i-1);

%Plots
plot(1:length(prob2),prob2,'r');
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
xlim([-1 1])


