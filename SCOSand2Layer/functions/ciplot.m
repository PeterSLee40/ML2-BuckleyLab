function ciplot(lower,upper,x,colour,alpha,edgc)
% ciplot(lower,upper)       
% ciplot(lower,upper,x)
% ciplot(lower,upper,x,colour)
%
% Plots a shaded region on a graph between specified lower and upper confidence intervals (L and U).
% l and u must be vectors of the same length.
% Uses the 'fill' function, not 'area'. Therefore multiple shaded plots
% can be overlayed without a problem. Make them transparent for total visibility.
% x data can be specified, otherwise plots against index values.
% colour can be specified (eg 'k'). Defaults to blue.
%
%alpha is the degree of transparency of the shaded region.  If alpha is 1,
%the region is completely opaque and if it is 0, the region if completely
%transparent.
%
%edgc is the color of the lines bordering the CI.
%
% Raymond Reynolds 24/11/06

if ~exist('alpha','var')
    alpha = 1;
end

if ~exist('edgc','var')
    edgc = 'k';
end

if length(lower)~=length(upper)
    error('lower and upper vectors must be same length')
end

if nargin<4
    colour='b';
end

if nargin<3
    x=1:length(lower);
end

% convert to row vectors so fliplr can work
if find(size(x)==(max(size(x))))<2
x=x'; end
if find(size(lower)==(max(size(lower))))<2
lower=lower'; end
if find(size(upper)==(max(size(upper))))<2
upper=upper'; end

fill([x fliplr(x)],[upper fliplr(lower)],colour,'FaceAlpha',alpha,'EdgeColor',edgc)
