function[xx] = unshsca(x,l,u,DS)
%UNSHSCA Unshift and unscale
%
%  xx = UNSHSCA(x,l,u,DS); vector x is shifted and scaled to yield xx.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:48:14 $

arg2 = (l== -inf) & (u < inf); 
arg3 = (l> -inf) & (u == inf);
arg4 = (l > -inf) & (u < inf);
%
% UNSCALE
xx = full(DS*x);   % always full except in scalar case.
%
% UNSHIFT
xx(arg2) = xx(arg2) + u(arg2) - 1; 
xx(arg3) = xx(arg3) + l(arg3);
xx(arg4) = xx(arg4) + l(arg4);
