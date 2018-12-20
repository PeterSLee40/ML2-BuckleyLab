
function maxwindows(figurehandle)
%MAXWINDOW - Maximize figure window
%
%Syntax: maxwindow

screen=get(0,'screensize');
if screen(3)==800
 set(figurehandle,'Units','normalized','Position',[0 0.0467 1.00 0.84])
elseif screen(3)==1024
 set(figurehandle,'Units','normalized','Position',[0.00 0.032 1.00 0.92])
elseif screen(3)==1152
 set(figurehandle,'Units','normalized','Position',[0.00 0.032 1.00 0.89])
elseif screen(3)==1280
 set(figurehandle,'Units','normalized','Position',[0.00 0.032 1.00 0.895])
elseif screen(3)==1440
 set(figurehandle,'Units','normalized','Position',[0.00 0.032 1.00 0.895])
%elseif screen(3)==1600
elseif screen(3)>1600
 set(figurehandle,'Units','normalized','Position',[0.00 0.032 0.7 1.0])
end 
 