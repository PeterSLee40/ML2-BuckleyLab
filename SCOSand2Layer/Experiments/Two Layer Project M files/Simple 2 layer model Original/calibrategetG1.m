function cost = calibrategetG1(mult,expectedg1, n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2, gl)
db1 = db1*mult;
db2 = db2*mult;
g1 = getG1(n,Reff,mua1,mus1,db1,tau,lambda,rho',w,l,mua2,mus2,db2, gl);
cost = norm(2*(expectedg1-1) - g1.^2).^2;
end 