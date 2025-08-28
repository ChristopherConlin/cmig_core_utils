function P = siemens_legendre(n,X)
% Siemens-style Legendre polynomials
% P = siemens_legendre(n,X)

% (from Anders -- originally from Siemens?)

P = legendre(n,X);

for m=1:n
   normfact = (-1)^m*sqrt((2*n+1)*factorial(n-m)/(2*factorial(n+m)));
   P(m+1,:) = normfact*P(m+1,:);
end

return;
