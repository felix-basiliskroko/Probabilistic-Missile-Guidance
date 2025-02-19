%% Auxiliary Functions

function profile = thrustprofile(t)
     profile = 0;
     if t < 10 && t>=0
         profile = 11000;
     elseif t < 30 && t>= 10
         profile = 1800;
     elseif t > 30
         profile = 0;
     end

end