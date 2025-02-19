%% Clear commands & setup environment
clearvars; % Use clearvars instead of clear all to avoid wiping functions
close all;
clc;

%% Define Global Constants
g = 9.81; % Gravity (m/s^2)
time = 500; % Simulation time (s)
Ts = 0.1;   % Time step (s)
num_steps = round(time / Ts); % Ensure valid number of steps

% Detection threshold (detonation range in meters)
detonation_threshold = 10; 

%% Define Grid of Initial Conditions
VP_values = linspace(400, 600, 5); % Missile velocity (m/s)
gammaP_values = linspace(-0.1, 0.1, 3); % Missile flight path angle (rad)
VE_values = linspace(400, 600, 5); % Evader velocity (m/s)
gammaE_values = linspace(pi - 0.1, pi + 0.1, 3); % Evader flight path angle (rad)
hE_values = linspace(8000, 12000, 3); % Evader initial altitude (m)
dE_values = linspace(25000, 35000, 3); % Evader initial downrange position (m)

%% Define Output File
filename = 'kin_engagement_dataset.csv';

% Create table headers (overwrite old file)
headers = table([], [], [], [], [], [], [], [], ...
    'VariableNames', {'VP', 'gammaP', 'VE', 'gammaE', 'hE', 'dE', 'Hit_Flag', 'Miss_Distance'});
writetable(headers, filename);

%% Simulation Loop Over Initial Conditions
for VP = VP_values
    for gammaP = gammaP_values
        for VE = VE_values
            for gammaE = gammaE_values
                for hE = hE_values
                    for dE = dE_values

                        % Define Initial Conditions
                        beta_0 = 0;  % Initial line-of-sight angle
                        R_0 = sqrt((dE - 0)^2 + (hE - 10000)^2); % Initial separation

                        x0_dyn = [VP, gammaP, 10000, 0, VE, gammaE, hE, dE]; % Missile & target state

                        % Initialize storage for state variables
                        x2 = zeros(8, num_steps);

                        % Initialize detonation status
                        detonate = 0;
                        missDistance = NaN;

                        % Run Simulation
                        for ii = 1:num_steps
                            if ii == 1
                                [~, xx] = ode45(@(t,x)dynsim(t,x), [ii ii+1]*Ts, x0_dyn);
                            else
                                [~, xx] = ode45(@(t,x)dynsim(t,x), [ii ii+1]*Ts, x2(:,ii-1));
                            end
                            x2(:,ii) = xx(end,:);
                            
                            % Check for detonation
                            [detonate, missDistance] = fuze(xx);
                            if detonate
                                break; % Stop simulation on hit
                            end
                        end

                        % Store results in a table
                        new_entry = table(VP, gammaP, VE, gammaE, hE, dE, detonate, missDistance);

                        % Append results to the file
                        writetable(new_entry, filename, 'WriteMode', 'append');

                        % Display progress in console
                        fprintf('Simulated: VP=%.1f, gammaP=%.3f, VE=%.1f, gammaE=%.3f, hE=%.1f, dE=%.1f → Hit: %d, Miss Dist: %.2f\n', ...
                            VP, gammaP, VE, gammaE, hE, dE, detonate, missDistance);
                    end
                end
            end
        end
    end
end

fprintf('Simulation completed. Results saved in %s\n', filename);
