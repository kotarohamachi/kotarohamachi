clc
clear all
close all

% load the data
startdate = ['01/01/1994'];
enddate = '01/01/2022';
f = fred
D = fetch(f,'CLVMNACSCAB1GQDE',startdate,enddate)
J = fetch(f,'JPNRGDPEXP',startdate,enddate)
d = log(D.Data(:,2));
j = log(J.Data(:,2));
q = D.Data(:,1);

T = size(d,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauDEGDP = A\d;
tauJPGDP = A\j;

% detrended GDP
dtilde = d-tauDEGDP;
jtilde = j-tauJPGDP;

% plot detrended GDP
dates = 1954:1/4:2022.1/4; zerovec = zeros(size(d));
figure
title('Detrended log(real GDP) 1954Q1-2019Q1'); hold on
plot(q, dtilde,'b', q, jtilde,'r')
legend('Germany','Japan')
datetick('x', 'yyyy-qq')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
dsd = std(dtilde)*100;
jsd = std(jtilde)*100;
corryc = corrcoef(dtilde(1:T),jtilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for D: ', num2str(dsd),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP for J: ', num2str(jsd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corryc),'.']);



