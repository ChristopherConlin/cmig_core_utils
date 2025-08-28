function AeraXJParams = gradParamsAeraXJ

% Spherical harmonic parameters for the Aera XJ gradients

AeraXJParams.R0 = 0.250;

% Allocate memory
AeraXJParams.Alpha_x = zeros(30,30);
AeraXJParams.Alpha_y = zeros(30,30);
AeraXJParams.Alpha_z = zeros(30,30);
AeraXJParams.Beta_x = zeros(30,30);
AeraXJParams.Beta_y = zeros(30,30);
AeraXJParams.Beta_z = zeros(30,30);

% X gradient
AeraXJParams.Alpha_x(1+ 3, 1 +1) = -0.09648;
AeraXJParams.Alpha_x(1+ 3, 3 +1) = -0.01377;
AeraXJParams.Alpha_x(1+ 5, 1 +1) = -0.07734;
AeraXJParams.Alpha_x(1+ 5, 3 +1) =  0.00494;
AeraXJParams.Alpha_x(1+ 5, 5 +1) =  0.00182;
AeraXJParams.Alpha_x(1+ 7, 1 +1) =  0.03187;
AeraXJParams.Alpha_x(1+ 7, 3 +1) =  0.00104;
AeraXJParams.Alpha_x(1+ 7, 5 +1) = -0.00260;
AeraXJParams.Alpha_x(1+ 7, 7 +1) =  0.00052;
AeraXJParams.Alpha_x(1+ 9, 1 +1) = -0.00762;
AeraXJParams.Alpha_x(1+ 9, 3 +1) = -0.00043;
AeraXJParams.Alpha_x(1+ 9, 5 +1) =  0.00147;
AeraXJParams.Alpha_x(1+ 9, 7 +1) = -0.00026;

% Y gradient
AeraXJParams.Beta_y(1+ 3,1 +1) = -0.10003;
AeraXJParams.Beta_y(1+ 3,3 +1) =  0.00840;
AeraXJParams.Beta_y(1+ 5,1 +1) = -0.07456;
AeraXJParams.Beta_y(1+ 5,3 +1) = -0.00121;
AeraXJParams.Beta_y(1+ 5,5 +1) = -0.00061;
AeraXJParams.Beta_y(1+ 7,1 +1) =  0.03170;
AeraXJParams.Beta_y(1+ 7,3 +1) = -0.00303;
AeraXJParams.Beta_y(1+ 7,5 +1) = -0.00173;
AeraXJParams.Beta_y(1+ 7,7 +1) =  0.00009;
AeraXJParams.Beta_y(1+ 9,1 +1) = -0.00831;
AeraXJParams.Beta_y(1+ 9,3 +1) =  0.00147;
AeraXJParams.Beta_y(1+ 9,5 +1) =  0.00095;
AeraXJParams.Beta_y(1+ 9,7 +1) =  0.00026;
AeraXJParams.Beta_y(1+ 9,9 +1) = -0.00017;

% Z gradient
AeraXJParams.Alpha_z(1+  3, 0 +1) = -0.10800;
AeraXJParams.Alpha_z(1+  5, 0 +1) = -0.09360;
AeraXJParams.Alpha_z(1+  7, 0 +1) =  0.06020;
AeraXJParams.Alpha_z(1+  9, 0 +1) = -0.02200;
AeraXJParams.Alpha_z(1+ 11, 0 +1) =  0.00340;
AeraXJParams.Alpha_z(1+ 13, 0 +1) = -0.00240;
AeraXJParams.Alpha_z(1+ 15, 0 +1) = -0.00310;
