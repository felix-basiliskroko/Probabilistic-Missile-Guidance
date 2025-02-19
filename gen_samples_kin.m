% Driver Code

%% Clear commands
clear all
close all
clc

%% Define ranges for initial conditions using bin-based partitioning
hP_vals = linspace(5000, 15000, 8);     % Range for pursuer altitude (meters)
dP_vals = linspace(0, 20000, 8);        % Range for pursuer horizontal position (meters)
gammaP_vals = linspace(deg2rad(-20), deg2rad(20), 8); % Range for pursuer flight path angle (radians)
hE_vals = linspace(5000, 15000, 8);     % Range for evader altitude (meters)
dE_vals = linspace(0, 20000, 8); % Range for evader horizontal position (meters)
gammaE_vals = linspace(deg2rad(-20), deg2rad(20), 8); % Range for evader flight path angle (radians)
beta_vals = linspace(deg2rad(-20), deg2rad(20), 8); % Range for initial LOS angle (radians)

%% Output file setup
filename = 'kin_engagement_dataset.csv';
fid = fopen(filename, 'w');
header = 'hP,dP,gammaP,hE,dE,gammaE,beta,hit_flag,miss_distance,hit_time\n';
fprintf(fid, header);

%% Initialize simulation counter
total_simulations = 0;
estimated_total = numel(hP_vals) * numel(dP_vals) * numel(gammaP_vals) * numel(hE_vals) * numel(dE_vals) * numel(gammaE_vals) * numel(beta_vals);

%% Loop over all combinations of initial conditions
for hP = hP_vals
    for dP = dP_vals
        for gammaP = gammaP_vals
            for hE = hE_vals
                for dE = dE_vals
                    for gammaE = gammaE_vals
                        for beta = beta_vals

                            total_simulations = total_simulations + 1; % Count each simulation
                            
                            if mod(total_simulations, 1000) == 0 || total_simulations == 1
                                fprintf('Progress: %d/%d simulations completed.\n', total_simulations, estimated_total);
                            end

                            %% Compute initial relative distance R
                            R_0 = sqrt((hE - hP)^2 + (dE - dP)^2);
                            
                            %% Define initial state vector
                            x0_kin = [hP, dP, gammaP, hE, dE, gammaE, R_0, beta];
                            
                            %% Simulation parameters
                            time = 500; % seconds
                            Ts = 0.1;
                            x = zeros(8, time/Ts);
                            hit_flag = false; % Initialize hit flag
                            t_hit = NaN; % Initialize hit time as NaN
                            
                            %% Run simulation
                            for ii = 1:time/Ts
                                if ii == 1
                                    [~, xx] = ode45(@(t, x) kinsim(t, x), [ii ii+1] * Ts, x0_kin);
                                else
                                    [~, xx] = ode45(@(t, x) kinsim(t, x), [ii ii+1] * Ts, x(:, ii-1));
                                end
                                x(:, ii) = xx(end, :);
                                
                                %%% Intersample Fuzing %%%%%%%%
                                [detonate, missDistance] = fuzeKin(xx);
                                if detonate
                                    hit_flag = true;
                                    t_hit = ii * Ts;
                                    break;
                                end
                            end
                            
                            % If no detonation occurred, get final miss distance
                            if ~hit_flag
                                missDistance = x(7, ii);
                            end
                            
                            %% Write data to CSV file
                            fprintf(fid, '%.2f,%.2f,%.4f,%.2f,%.2f,%.4f,%.4f,%d,%.4f,%.1f\n', ...
                                    hP, dP, gammaP, hE, dE, gammaE, beta, hit_flag, missDistance, t_hit);
                        end
                    end
                end
            end
        end
    end
end

%% Close file
fclose(fid);

%% Print total number of simulations
fprintf('Total simulations completed: %d/%d\n', total_simulations, estimated_total);

disp('Simulation complete. Results saved in kin_engagement_dataset.csv');