function subhandle = loopchoose(n,k)
% loopchoose: returns the combinations that nchoosek would, but does it iteratively
% usage 1: subhandle = loopchoose(n,k);   Initial call to set up loopchoose
% usage 2: subset = subhandle();        Subsequent calls
%
% LOOPCHOOSE exists for those occasions where nchoosek will overflow
% memory and the combinations can be generated in a loop, one at a time.
% Why use LOOPCHOOSE? Because c = nchoosek(1:20,10) is an array that
% requires 14780480 bytes of memory to store. LOOPCHOOSE can generate
% much larger sets of combinations without incurring a memory overflow.
%
% LOOPCHOOSE is also not that terribly slow. whereas nchoosek(1:20,10)
% had an ellapsed time of 18.350041 seconds on my computer, the
% LOOPCHOOSE loop took less than twice as long, only 32.721433 seconds.
% 
% arguments: (initial call, input)
%   n - scalar integer - size of total set
%       If this mode is used, then the output of the function handle
%       will be the integers 1:n.
%       
%       Alternatively, n can be a vector, of length n. In this event,
%       the output from the function handle will be appropriately chosen
%       elements of this vector.
%
%   k - scalar integer - size of the subsets chosen
%
% arguments: (initial call, output)
%   subhandle - a function handle to a nested function that will
%       return subsequent subsets.
%
%
% arguments: (subsequent calls, input)
%   On subsequent calls to the returned function handle, no input
%   arguments are required. subhandle is a nested function handle.
% 
% arguments: (output)
%   subset - a subset (of length k) of the integers 1:n, or of the
%       elements of the vector n.
%
% 
% Example usage:
%  Generate all subsets of the integers 1:4, taken 2 at a time.
%  (Note that most usages of loopchoose would use much larger sets.)
% 
%  subhandle = loopchoose(4,2); % initialization call
%  p = nchoosek(4,2);
%  combos = zeros(p,2);
%  for i = 1:p
%    combos(i,:) = subhandle(); % subsequent calls
%  end
%
%  combos
%  combos =
%     1     2
%     1     3
%     1     4
%     2     3
%     2     4
%     3     4
%
%
% Example usage:
%  Generate all subsets of the integers [2 3 5 7 11 13 17 19 23 29],
%  taken 4 at a time.
% 
%  subhandle = loopchoose(primes(30),4); % initialization call
%  
%  subhandle(), % function handle calls
%  ans =
%      2     3     5     7
%
%  subhandle()
%  ans =
%      2     3     5    11
%
%  subhandle()
%  ans =
%      2     3     5    13
%
%
% See also: nchoosek
%
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 12/6/2006

% The initial call to set up the problem

% First, check for errors
vec = [];
if (length(n)~=1)
  % n was a vector.
  vec = n(:)';
  n = length(vec);
elseif (n<1) || (n~=floor(n))
  error 'n must be a scalar positive integer'
elseif (k>n) || (k<1) || (k~=floor(k))
  error 'k must be a positive integer, k<=n'
end
% did we get a vector for n?
vecflag = ~isempty(vec);

% set of all possible elements
tset = 1:n;

% Return a function handle to a nested function that does the
% actual work
subhandle = @choosenext;

% This is the current subset. If empty, then this is the first call.
currentsubset = [];

% done until calls to choosenext
return

% ===================================
%   nested function
% ===================================
function returnedset = choosenext
% called with no arguments, all information is retained
% in the nested function.

if isempty(currentsubset)
  % Initial subset
  subset = 1:k;
else
  % This must be a subsequent call. figure out the next subset.
  
  if currentsubset(1) == (n-k+1)
    % Already returned the last combination in the set.
    subset = [];
    return
  end
  
  % finally, we can get to work
  last = currentsubset(end);
  if last < n
    % we can just increment the last element
    subset = currentsubset;
    subset(end) = last+1;
  else
    % The last element was already maxed.
    d = diff(currentsubset);
    L = find(d>1,1,'last');
    subset = currentsubset;
    subset(L) = subset(L)+1;
    subset(L+1:end) = subset(L) + (1:(k-L));
  end
  
end

% save currentsubset for the next call
currentsubset = subset;

% was a vector provided in n?
if vecflag
  returnedset = vec(subset);
else
  returnedset = subset;
end

% done with this nested call
end

% mainline end
end

