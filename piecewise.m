%% Auxiliary functions

function k = piecewise(g,t)
     if t < 9 && t>=0
         k = -8*g;
     elseif t<10 && t>=9
         k = 0 * g;
     elseif t < 22 && t>=10
         k = -6 * g;
     elseif t >= 22
         k = 0 * g;
     end

end