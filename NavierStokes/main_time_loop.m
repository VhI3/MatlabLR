
nSteps = length(time);
% time = linspace(0,30,nSteps);
% k = time(2)-time(1);
k = delta_time;
N = n1+n2+n3;
u    = zeros(N,1);
% u(lru.getEdge(4)) = 1;
uAll = zeros(N,nSteps);
uAll(:,1) = u;


% lhs = [M+k*A, k*D; D', zeros(n3,n3)];
lhs = [M+k*A, k*D; Dt, [avg_p'; zeros(n3-1,n3)]];
% lhs = [M, zeros(n1+n2,n3); zeros(n3,N)] + k*dF(1);
b   = b(1:(n1+n2));
% lhs(edges,:) = [];
% lhs(:,edges) = [];

% [plotAu meshu eu xu yu] = lru.getSurfMatrix('diffX', 'parametric', 'nviz', 5, 'diffX');
% [plotAv meshu ev xv yv] = lrv.getSurfMatrix('diffY', 'parametric', 'nviz', 5, 'diffY');
[plotA plotB mesh edges x y] = getSurfacePlotMatrices(lr, lru, lrv, lrp, 4);
title    = sprintf('%s, %s (%s)', Problem.Title, Problem.Subtitle, Problem.Identifier);
writeVTK2(sprintf('%s-%d.vtk', filename, 1), title, x,y,mesh, zeros(numel(x),1),zeros(numel(x),1), zeros(numel(x),1));

topRightCorner = intersect(lrp.getEdge(2), lrp.getEdge(4))+n1+n2;

timer = cputime; tic;
for i=2:nSteps
  lastTime = toc;
  fprintf('Time: %g (step %d/%d):\n', time(i), i, nSteps);

  % initial guess for newton stepping = previous time step
  v  = u; %zeros(n1+n2+n3,1);
  n  = n1+n2;
  N  = n1+n2+n3;
  for newtIt=1:nwtn_max_it
    %%% backward euler stepping
    % lhs = [M, zeros(n,n3);    zeros(n3,N)] + k*dF(v);
    % rhs = [M*(v(1:n)-u(1:n)); zeros(n3,1)] + k* F(v);
    %%% crank-nicolson rule stepping
    lhs = [M, zeros(n,n3);    zeros(n3,N)] + k/2*(dF(v)       );
    rhs = [M*(v(1:n)-u(1:n)); zeros(n3,1)] + k/2*( F(v)+ F(u) );
    % max(max(abs(rightLHS-lhs)))
    % max(max(abs(rightRHS-rhs)))
    % rhs(edges) = 0;
    dv = lhs \ -rhs;
    v = v + dv;
    if(norm(dv)<nwtn_res_tol)
      break;
    end
  end
  fprintf('  Newton iteration converged after %d iterations at residual %g\n', newtIt, norm(dv));
  fprintf('  Pressure at top right corner %g\n', v(topRightCorner));
  u = v;
  vel = plotA*u(1:n);
  pressure = plotB*u(n+1:end);
  velX     = vel(1:end/2  );
  velY     = vel(  end/2+1:end);
  writeVTK2(sprintf('%s-%d.vtk', filename, i), title, x,y,mesh, velX,velY,pressure);


  % u = [M+k/2*A, k/2*D; Dt [avg_p'; zeros(n3-1,n3)]] \ [(M-k/2*A)*u(1:n)-k/2*D*u(n+1:end)+k*b; zeros(n3,1)];
  % u = [M+k*A, k*D; Dt [avg_p'; zeros(n3-1,n3)]] \ [M*u(1:n)+k*b; zeros(n3,1)];
  % u = rightLHS \ rightRHS;
  % dudx = plotAu*u(1:n1);
  % dvdy = plotAv*u(n1+1:n1+n2);
  % divPt = dudx + dvdy;
  % fprintf('  max(div(u)) = %g\n', max(max(divPt)));
  timeUsed = toc - lastTime;
  timeLeft = (nSteps-i)*timeUsed;
  c = clock;
  c(6) = c(6) + floor(timeLeft);
  fprintf('  Estimated time left: ');
  if timeLeft>60*60*24
    fprintf('%d days, ', floor(timeLeft/60/60/24));
    timeLeft = mod(timeLeft,60*60*24);
  end
  if timeLeft>60*60
    fprintf('%d hours, ', floor(timeLeft/60/60));
    timeLeft = mod(timeLeft,60*60);
  end
  if timeLeft>60
    fprintf('%d minutes and ', floor(timeLeft/60));
    timeLeft = mod(timeLeft,60);
  end
  fprintf('%d seconds\n', floor(timeLeft));
  fprintf('  Estimated completion: %s\n', datestr(datetime(c)));

  uAll(:,i) = u;
end
fprintf('\n');
time_timeStepping = cputime - timer; time_timeStepping_wall = toc;
