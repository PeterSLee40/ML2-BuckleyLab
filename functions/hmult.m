function W = hmult(Hinfo,Y,varargin)
%HMULT	Hessian-matrix product
%
% W = HMULT(Y,Hinfo) An example of a Hessian-matrix product function
% file, e.g. Hinfo is the actual Hessian and so W = Hinfo*Y.
%
% Note: varargin is not used but must be provided in case 
% the objective function has additional problem dependent
% parameters (which will be passed to this routine as well).

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:47:35 $

W = Hinfo*Y;





