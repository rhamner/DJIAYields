function rate = actualRate(payment, fv, years)
%calculate actual rate by guessing a yield, comparing its fv with actual
%fv, and repeating

err = 1000000000000000000000000;
rate = 0;
for r = -1:.001:1
    calcFv = payment*((power(1 + r/12, years*12) - 1)/(r/12));
    if(abs(fv - calcFv) < err)
        err = abs(fv - calcFv);
        rate = r;
    end
end
