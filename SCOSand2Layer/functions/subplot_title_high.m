function title_handle=subplot_title_high(title_string)

ax = gca;
 fig = gcf;
 
 title_handle = axes('position',[.1 0.88 .8 .05],'Box','off','Visible','off');
 
 title(title_string);
 set(get(gca,'Title'),'Visible','On');
 set(get(gca,'Title'),'FontSize',30);
 set(get(gca,'Title'),'FontWeight','bold');
 axes(ax);