%   to annote a figure with a textbox

function figannote(objfig,str,fontsize)
    figure(objfig)
    an=annotation('textbox',[0.35 0.9 0.3 0.1],'Interpreter','latex')
    set(an,'String', str)
    set(an,'VerticalAlignment','middle')
    set(an,'HorizontalAlignment','center')
    set(an,'FontSize',fontsize);
%     set(an,'FitHeightToText','on');
    set(an,'Interpreter','latex');
    set(an,'LineStyle','none');