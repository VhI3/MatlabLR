clear; close all;

Problem = struct(...
'Title'             ,  'Cavity',...
'Subtitle'          ,  'vtk-test',  ...
'Identifier'        ,  'a',     ...
'Polynomial_Degree' ,  [2,2],   ...
'H_Max'             ,  1/6,    ...
'H_Min'             ,  1/6,    ...
'Reynolds'          ,  100,     ...
'Newton_TOL'        ,  1e-10,   ...
'Newton_Max_It'     ,  12,      ...
'Time_Range'        ,  [0,1]);

main_init;
main_getGeom;
main_assemble;
main_time_loop;
% main_plot;
main_dump_results;
