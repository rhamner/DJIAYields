clear all
close all

f = fopen(filepath, 'r');
data = textscan(f, '%s\t%s\t%f\t%f\t%f', 'headerlines', 1, 'delimiter', ',');
fclose(f);

years = 30;
months = years*12;
inflationAdj = data{3};
raw = data{4};
treasury = data{5};
effectiveInf = inflationAdj./raw;

%calculate annual inflation
j = 1;
year(1) = 1915;
for i = 1:12:1224
    inflation(j) = effectiveInf(i)/effectiveInf(i + 12) - 1;
    j = j + 1;
    year(j) = year(j - 1) + 1;
end
year(j) = [];

for start = 1:876
    
    %set initial $100 investment
    res = 100;
    qres = 100;
    q = 100;
    tres = 100;
    comb = 100;
    
    %run through each month in the period
    for i = start:months + start
        
        %buy the dip strategy with a 1% loss threshold
        if(i > 1)
            change = (inflationAdj(i) - inflationAdj(i - 1))/inflationAdj(i - 1);
        else
            change = 0;
        end
        if(change < -0.01)
            qres = qres*(1 + change) + q;
            q = 100;
        else
            qres = qres*(1 + change);
            q = q + 100;
        end
        
        %calculate growth and inflation from this month to end of period
        growth = raw(months + start)/raw(i);
        inf = effectiveInf(months + start)/effectiveInf(i);
        
        %add this monthly deposit
        res = res + 100*growth*inf;
        tres = tres + 100*(power(1 + (treasury(i)/12), months + start - i)*inf);
        comb = comb + 75*growth*inf + 25*(power(1 + (treasury(i)/12), months + start - i)*inf);
    end
    
    %add any money not invested yet from buying the dip
    qres = qres + q;
    
    %convert future values, monthly deposits, and investment period into an
    %actual rate
    rate(start) = actualRate(100, res, years);
    time(start) = data{2}(start);
    qRate(start) = actualRate(100, qres, years);
    tRate(start) = actualRate(100, tres, years);
    combRate(start) = actualRate(100, comb, years);
end

%repeat basic calculation for the 10 year investment period
years = 10;
months = years*12;
for start = 1:876
    res = 100;
    for i = start:months + start
        growth = raw(months + start)/raw(i);
        inf = effectiveInf(months + start)/effectiveInf(i);
        res = res + 100*growth*inf;
        tres = tres + 100*(power(1 + (treasury(i)/12), months + start - i)*inf);
        comb = comb + 75*growth*inf + 25*(power(1 + (treasury(i)/12), months + start - i)*inf);
    end
    rate10(start) = actualRate(100, res, years);
end

%plot everything
figure(1)
hist(rate)

fig = figure(2)
set(fig, 'position', [200 50 1150 650])
plot(datenum(time), 100*rate, 'linewidth', 2)
datetick
title('30 years of monthly investments (DOW)', 'fontsize', 18)
ylabel('real yield (%)', 'fontsize', 14)
xlabel('investment start date', 'fontsize', 14)
set(gca, 'Fontsize', 14, 'ticklength', [0,0])
grid on

fig = figure(3)
set(fig, 'position', [200 50 1150 650])
plot(datenum(time), 100*rate, 'linewidth', 2)
hold on
plot(datenum(time), 100*qRate, 'linewidth', 2)
legend('Monthly', 'Buy the Dip')
datetick
title('30 years of monthly investments (DOW) - buy the dip', 'fontsize', 18)
ylabel('real yield (%)', 'fontsize', 14)
xlabel('investment start date', 'fontsize', 14)
set(gca, 'Fontsize', 14, 'ticklength', [0,0])
grid on

fig = figure(4)
set(fig, 'position', [200 50 1150 650])
plot(datenum(time), 100*rate10, 'linewidth', 2)
datetick
title('10 years of monthly investments (DOW)', 'fontsize', 18)
ylabel('real yield (%)', 'fontsize', 14)
xlabel('investment start date', 'fontsize', 14)
set(gca, 'Fontsize', 14, 'ticklength', [0,0])
grid on

fig = figure(5)
set(fig, 'position', [200 50 1150 650])
plot(datenum(time), 100*tRate, 'linewidth', 2)
datetick
title('30 years of monthly investments (treasuries)', 'fontsize', 18)
ylabel('real yield (%)', 'fontsize', 14)
xlabel('investment start date', 'fontsize', 14)
set(gca, 'Fontsize', 14, 'ticklength', [0,0])
grid on

fig = figure(6)
set(fig, 'position', [200 50 1150 650])
plot(datenum(time), 100*rate, 'linewidth', 2)
hold on
plot(datenum(time), 100*tRate, 'linewidth', 2)
plot(datenum(time), 100*combRate, 'linewidth', 2)
legend('DOW', 'Treasuries', '75/25 Mix')
datetick
title('30 years of monthly investments', 'fontsize', 18)
ylabel('real yield (%)', 'fontsize', 14)
xlabel('investment start date', 'fontsize', 14)
set(gca, 'Fontsize', 14, 'ticklength', [0,0])
grid on

fig = figure(7)
set(fig, 'position', [200 50 1150 650])
plot(year, 100*inflation, 'linewidth', 2)
title('CPI (Inflation)', 'fontsize', 18)
ylabel('rate (%)', 'fontsize', 14)
xlabel('year', 'fontsize', 14)
set(gca, 'Fontsize', 14, 'ticklength', [0,0])
grid on

