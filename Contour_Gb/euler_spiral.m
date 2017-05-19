function [k_fin, L_fin, gamma] = solveEuler(x0, y0, theta0, x2, y2, theta2, iter)
[estK_init, estL_init] = computeInitialEstimates(x0, y0, theta0, x2, y2, theta2);
[k_fin, L_fin] = solveIteratively(x0, y0, theta0, x2, y2, theta2);
gamma = 2 * (theta2 - theta0 - k_fin * L_fin) / L_fin;
end

function [estK_init, estL_init] = computeInitialEstimates(x0, y0, theta0, x2, y2, theta2)