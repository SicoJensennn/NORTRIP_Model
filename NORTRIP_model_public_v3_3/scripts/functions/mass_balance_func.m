function M = mass_balance_func(M_0,P,R,dt)
% mass_balance_func: Caclulates temporal mass balance changes
% Depends on:

if P<R*1e8,
    M=P./R.*(1-exp(-R.*dt))+M_0.*exp(-R.*dt);
else
    M=M_0+P.*dt;
end

end

