clc
clear all
%Asigna los tiempos de llegada al receptor (tx_time) segï¿½n el patrï¿½n de pï¿½rdidas lp.
n = 1000;
N_pkts = n;
loss = 0.01;
loss2 = 0.01;
lp = 1>(rand(1,N_pkts/2)/loss);
lp = [lp 1>(rand(1,N_pkts/2)/loss2)];
%Inicializaciï¿½n

lp=lp';

cwnd = zeros(1,ceil(N_pkts));

ptr = 1;
cwnd(1) = 4;

%New CWND Algorithm (initialization)
decCwnd = cwnd(1)*3;
minCwnd = cwnd(1);
maxCwnd = cwnd(1);
alpha = 0.97743;
averageCwnd = cwnd(1);
average = [cwnd(1) zeros(1,N_pkts-1)];
var = 0.5; %Maximum variation before changing cwnd
incrementIni = 1;
incrementPerm = 0.08;
increment = incrementIni;
fastStart = 0;

%Normal TCP initialization for comparison purposes
cwnd2 = zeros(1,ceil(N_pkts));
cwnd2(1) = 4;
ptr2 = 1;
ss = 0;

for j=1:N_pkts
    comp = sum(lp(ptr:min(ptr+cwnd(j)-1,N_pkts))); % perdidas por ventana de congestion
    comp2 = sum(lp(ptr2:min(ptr2+cwnd2(j)-1,N_pkts)));
    
    %New TCP
    if comp>0
        maxCwnd = decCwnd;
        averageCwnd = abs(maxCwnd+minCwnd)/2;
        decCwnd = averageCwnd*alpha; 
        minCwnd = decCwnd;
        increment = increment/2;
        if fastStart <= 1
            cwnd(j+1) = cwnd(j) + 1;
            fastStart = fastStart + 1;

        end
        if increment <= incrementPerm
            increment = incrementPerm;
        end
    else
        decCwnd = decCwnd + averageCwnd/decCwnd*increment;
    end
    if fastStart <= 1 && comp == 0
        cwnd(j+1) = cwnd(j) + 1;
    end
    if (decCwnd-cwnd(j))/cwnd(j) >= var 
        cwnd(j+1) = cwnd(j) + 1 ;
    elseif (decCwnd-cwnd(j))/cwnd(j) <= -var
        cwnd(j+1) = cwnd(j) - 1;
    
    else
        cwnd(j+1) = cwnd(j);
    end
    ptr = ptr+cwnd(j);
    if ptr>length(lp)
        break
    end
    
    %Old TCP
    if comp2>0
        ptr2 = ptr2+cwnd2(j);
        cwnd2(j+1)=max(floor(cwnd2(j)/2),2);
        ss = 0;
    else
        ptr2 = ptr2+cwnd2(j);
        if (ss)
            cwnd2(j+1)=cwnd2(j)*2;
        else
            cwnd2(j+1)=cwnd2(j)+1;
        end
    end
    if ptr2>length(lp)
        break
    end
    
end

cwnd = cwnd(1:j);
cwnd2 = cwnd2(1:j);
plot(cwnd2, '-b');
hold on
plot(cwnd, '-r')
xlabel('Número de Ventana')
ylabel('Tamaño de la Ventana')
title('Comparación entre algoritmos')
%disp(['promedio de ventana: ' , num2str(mean(cwnd))]);





