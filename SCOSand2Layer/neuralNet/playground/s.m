theta = linspace(1,10*pi);
X = cos(theta);
Y = sin(theta);
Z = theta;
scatter3(X,Y,Z)
zlim manual
hold on 
Znew = 5*theta;
scatter3(X,Y,Znew)
hold off