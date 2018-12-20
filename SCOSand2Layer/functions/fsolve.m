function [x,OPTIONS] = fsolve(FUN,x,OPTIONS,GRADFUN,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10)
%FSOLVE Solves by a least squares method non-linear equations of the form:
%		      
%	F(X)=0    where F and X may be vectors or matrices.   
%
%	X=FSOLVE('FUN',X0) starts at the matrix X0 and tries to solve the 
%	equations described in FUN. FUN is usually and  M-file which returns 
%	an evaluation of the equations for a particular value of X: F=FUN(X).
%
%	X=FSOLVE('FUN',X0,OPTIONS) allows a vector of optional parameters to
%	be defined. OPTIONS(2) is a measure of the precision required for the 
%	values of X at the solution. OPTIONS(3) is a measure of the precision
%	required of the objective function at the solution. See HELP FOPTIONS. 
%
%	X=FSOLVE('FUN',X0,OPTIONS,'GRADFUN') enables a function'GRADFUN'
%	to be entered which returns the partial derivatives of the functions,
%	dF/dX, (stored in columns) at the point X: gf = GRADFUN(X).
%
%	The default algorithm is the Gauss-Newton method with a 
%	mixed quadratic and cubic line search procedure.  A Levenberg-Marquardt 
%	method is selected by setting  OPTIONS(5)=1. 

%	Copyright (c) 1990 by the MathWorks, Inc.
%	Andy Grace 7-9-90.

%	X=FSOLVE('FUN',X,OPTIONS,GRADFUN,P1,P2,..) allows
%	coefficients, P1, P2, ... to be passed directly to FUN:
%	F=FUN(X,P1,P2,...). Empty arguments ([]) are ignored.

% Handle undefined arguments
if nargin<4
	GRADFUN=[];
	if nargin<3
		OPTIONS=[];
	end
end

% Check if optimization toolbox is on path 
if exist('leastsq') 
	if length(GRADFUN)  & ~isstr(GRADFUN) 
		disp('The user-supplied gradient (Jacobian) must be a string.');
		error('The syntax to fsolve has been changed  - refer to the Optimization Toolbox guide');
	end

	if length(OPTIONS)<5; 
		OPTIONS(5)=0; 
	end
% Switch methods making Gauss Newton the default method.
	if OPTIONS(5)==0; OPTIONS(5)=1; else OPTIONS(5)=0; end

	evalstr='leastsq(FUN,x,OPTIONS,GRADFUN';

	for i=1:nargin - 4
		evalstr = [evalstr,',P',num2str(i)];
	end
	evalstr = [evalstr, ')'];

	[x, OPTIONS] = eval(evalstr);

	if OPTIONS(8)>10*OPTIONS(3) & OPTIONS(1)>0
		disp('Optimizer is stuck at a minimum that is not a root')
		disp('Try again with a new starting guess')
	end

else
% The old syntax:
	evalstr = 'fsolve2(FUN,x,OPTIONS,GRADFUN';
	for i=1:nargin - 4
		evalstr = [evalstr,',P',num2str(i)];
	end
	evalstr = [evalstr, ')'];
	[x, OPTIONS] = eval(evalstr);
end
