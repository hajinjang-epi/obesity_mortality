libname a 'C:\Users\HajinJang\Documents\hn';
libname b 'C:\Users\HajinJang\Documents\hn_coded';

data b.hn98_17_a;
set a.hn98_17_02;
run;

proc surveyreg data=b.hn98_17_a nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
class cage;
domain year*sex*occp;
model obe=cage/noint vadjust=none;
estimate '연도별 성별 직업과 비만율'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;
