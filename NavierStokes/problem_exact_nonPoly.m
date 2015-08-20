clear; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Square geometry with known exact solution (no slip boundary conditions)
%    u   = 2*exp(x)*(x-1)^2*x^2*(y^2-y)*(2*y-1);
%    v   = -exp(x)*(x-1)*x*(-2+x*(x+3))*(y-1)^2*y^2;
%    p   = (-424+156*exp(1)+(y^2-y)*(-456+exp(x)*(456+x^2*(228-5*(y^2-y))+2*x*(-228+(y^2-y))+2*x^3*(-36+(y^2-y))+x^4*(12+(y^2-y)))));
%
%   +--------+
%   |        |
%   | Omega  |
%   |        |
%   +--------+
%                                                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p  = 2; % polynomial degree. May be needed in Problem.Time_Step
Re = 1; % Reynolds number.   May be needed in Problem.Time_Step

Problem = struct(...
'Title'             ,  'PaperExact',  ...
'Subtitle'          ,  'non-poly',    ...
'Identifier'        ,  'a',        ...
'Geometry'          ,  'id',   ...
'Geometry_param'    ,  5,          ...
'Polynomial_Degree' ,  [p,p],      ...
'H_Max'             ,  1/2,        ...
'H_Min'             ,  1/2,        ...
'Reynolds'          ,  Re,         ...
'Geom_TOL'          ,  1e-10,      ...
'Newton_TOL'        ,  1e-10,      ...
'Newton_Max_It'     ,  12,         ...
'Force'             ,  @(x,y) [    ...
	exp(x)*(x^4*y^4 - 6*x^4*y^3 + 19*x^4*y^2 - 38*x^4*y + 12*x^4 + 6*x^3*y^4 - 36*x^3*y^3 + 18*x^3*y^2 + 60*x^3*y - 24*x^3 + x^2*y^4 - 6*x^2*y^3 + 19*x^2*y^2 - 38*x^2*y + 12*x^2 - 8*x*y^4 + 48*x*y^3 - 56*x*y^2 + 16*x*y + 2*y^4 - 12*y^3 + 14*y^2 - 4*y); ...
	76*x^3*exp(x) - 456*exp(x) - 238*x^2*exp(x) - 912*y - 10*x^4*exp(x) - 6*y^2*exp(x) + 12*y^3*exp(x) - 6*y^4*exp(x) + 460*x*exp(x) + 912*y*exp(x) - 932*x*y*exp(x) + 6*x*y^2*exp(x) + 506*x^2*y*exp(x) + 20*x*y^3*exp(x) - 164*x^3*y*exp(x) - 6*x*y^4*exp(x) + 14*x^4*y*exp(x) - 11*x^2*y^2*exp(x) - 58*x^2*y^3*exp(x) + 22*x^3*y^2*exp(x) + 19*x^2*y^4*exp(x) - 12*x^3*y^3*exp(x) + 7*x^4*y^2*exp(x) + 10*x^3*y^4*exp(x) + 2*x^4*y^3*exp(x) + x^4*y^4*exp(x) + 456], ...
'Static'            ,  true,       ...
'Linear'            ,  true,       ...
'Paraview'          ,  false,      ...
'MatlabPlot'        ,  false,       ...
'Save_Results'      ,  false,       ...
'Time_Step'         ,  .10,        ...
'Time_Range'        ,  [0,10]);
% 'Time_Step'         ,  @(h) min(h^((p+1)/2), h^2 /4*Re), ...

Exact_solution = struct(                  ...
'u',      @(x,y) 2*exp(x)*(x-1)^2*x^2*(y^2-y)*(2*y-1), ...
'v',      @(x,y) -exp(x)*(x-1)*x*(-2+x*(x+3))*(y-1)^2*y^2, ...
'p',      @(x,y) (-424+156*exp(1)+(y^2-y)*(-456+exp(x)*(456+x^2*(228-5*(y^2-y))+2*x*(-228+(y^2-y))+2*x^3*(-36+(y^2-y))+x^4*(12+(y^2-y))))), ...
'grad_u', @(x,y) [- 4*x*exp(x)*(- y^2 + y)*(2*y - 1)*(x - 1)^2 - 2*x^2*exp(x)*(- y^2 + y)*(2*x - 2)*(2*y - 1) - 2*x^2*exp(x)*(- y^2 + y)*(2*y - 1)*(x - 1)^2; 2*x^2*exp(x)*(2*y - 1)^2*(x - 1)^2 - 4*x^2*exp(x)*(- y^2 + y)*(x - 1)^2], ...
'grad_v', @(x,y) [- y^2*exp(x)*(x*(x + 3) - 2)*(x - 1)*(y - 1)^2 - x*y^2*exp(x)*(x*(x + 3) - 2)*(y - 1)^2 - x*y^2*exp(x)*(x*(x + 3) - 2)*(x - 1)*(y - 1)^2 - x*y^2*exp(x)*(2*x + 3)*(x - 1)*(y - 1)^2; - 2*x*y*exp(x)*(x*(x + 3) - 2)*(x - 1)*(y - 1)^2 - x*y^2*exp(x)*(x*(x + 3) - 2)*(2*y - 2)*(x - 1)] ...
);

BC     = cell(0);
BC = [BC, struct('pressure_integral', true)];
BC = [BC, struct('start', [0,0], 'stop', [1,0], 'comp', 2, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [0,1], 'stop', [1,1], 'comp', 2, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [0,0], 'stop', [0,1], 'comp', 1, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [1,0], 'stop', [1,1], 'comp', 1, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [0,0], 'stop', [1,0], 'comp', 1, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [0,1], 'stop', [1,1], 'comp', 1, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [0,0], 'stop', [0,1], 'comp', 2, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [1,0], 'stop', [1,1], 'comp', 2, 'value', 0, 'weak', false)];
BC = [BC, struct('start', [0,0], 'stop', [0,0], 'comp', 3, 'value', Exact_solution.p(0,0))];
BC = [BC, struct('start', [1,0], 'stop', [1,0], 'comp', 3, 'value', Exact_solution.p(1,0))];
BC = [BC, struct('start', [0,1], 'stop', [0,1], 'comp', 3, 'value', Exact_solution.p(0,1))];
BC = [BC, struct('start', [1,1], 'stop', [1,1], 'comp', 3, 'value', Exact_solution.p(1,1))];

if exist('Convergence_rates')
  if ~Problem.Static
    disp('Error: convergence rate simulations have to be couppled with static simulations')
    break;
  end
  result_h     = zeros(Convergence_rates.iterations,numel(Convergence_rates.p_values));
  result_uh_H1 = zeros(Convergence_rates.iterations,numel(Convergence_rates.p_values));
  result_ph_L2 = zeros(Convergence_rates.iterations,numel(Convergence_rates.p_values));

  for iteration_p=1:numel(Convergence_rates.p_values)
    Problem.Polynomial_Degree = ones(1,2)*Convergence_rates.p_values(iteration_p);
    main_init;
    h_val_result = Problem.H_Max;
    for iteration_h=1:Convergence_rates.iterations

      main_init_iteration
      main_assemble;
      main_static;
      integrateNorms;
      main_dump_iteration_results;

      result_h(    iteration_h, iteration_p) = h_val_result;
      result_uh_H1(iteration_h, iteration_p) = sqrt(sum(velocity_error_H1_squared)/sum(u_H1_norm_squared));
      result_ph_L2(iteration_h, iteration_p) = sqrt(sum(pressure_error_L2_squared)/sum(p_L2_norm_squared));
      
      disp 'pressure convergence results'
      diff(log(result_ph_L2)) ./ diff(log(result_h))
      disp 'velocity convergence results'
      diff(log(result_uh_H1)) ./ diff(log(result_h))
  
    end
  end
else
  main_init;
  main_assemble;

  if Problem.Static
    main_static;
    integrateNorms;
  else 
    main_time_loop;
  end

  main_dump_iteration_results;
end

main_dump_final_results


