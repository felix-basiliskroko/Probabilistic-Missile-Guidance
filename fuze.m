function [detonate, missDistance] = fuze(xx)
% Returns detonate = 1 if the missile truly detonates near the target.
% Otherwise, detonate = 0 and missDistance = NaN.

% Compute the missile-target separation distance
R = sqrt((xx(:,7) - xx(:,3)).^2 + (xx(:,8) - xx(:,4)).^2);

% Condition 1: Missile is within the hit radius (actual detonation)
proximity_hit = (R(2:end) < 10); % Check if R is below the threshold

% Condition 2: Missile crosses the target or reaches closest point
crossing_target = (R(2:end) .* R(1:end-1) < 0); % R switches sign (crosses)
moving_away = (R(2:end) - R(1:end-1) > 0); % R starts increasing (missed)
valid_detonation = any(proximity_hit & (crossing_target | moving_away)); 

% Condition 3: Missile hits the ground
missile_hits_ground = any(xx(2:end,3) < 0);

% Condition 4: Target hits the ground
target_hits_ground = any(xx(2:end,7) < 0);

% Condition 5: Missile runs out of speed
missile_stops = any(xx(2:end,1) < 0);

% Condition 6: Target runs out of speed
target_stops = any(xx(2:end,5) < 0);

% Determine if a valid hit occurred
if valid_detonation
    detonate = 1;
    missDistance = min(R); % Store closest approach distance
else
    detonate = 0;
    missDistance = NaN; % Ensure no false hits are recorded
end

% If the missile fails (hits ground, stops, or target stops), do NOT count as a hit
if missile_hits_ground || target_hits_ground || missile_stops || target_stops
    detonate = 0; % Mark as a failure instead of a successful hit
    missDistance = NaN;
end

end
