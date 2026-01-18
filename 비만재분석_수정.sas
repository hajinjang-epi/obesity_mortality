libname a 'C:\Users\HajinJang\Documents\hn';

data a.hn98_17;
set a.hn98_17;
if occp in (1,2) then occp_re=1;
if occp=3  then occp_re=2;
if occp=4 then occp_re=3;
if occp in (5,6) then occp_re=4;
if occp=7  then occp_re=5;
run;

/*-------------성별별로 보기(소득/연속형)--------------*/
proc surveyreg data=a.hn98_17 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
class cage sex occp_re region_re edu;
domain year*sex;
model obe=incm cage edu occp_re region_re /SOLUTION CLPARM noint vadjust=none;
estimate '성별별 소득과 비만율'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;

/*-------------교육수준과 비만율--------------*/
proc surveylogistic data=a.hn98_17 nomcar;
strata kstrata;
cluster psu;
weight wt_pool_2;
class cage sex occp_re region_re edu;
model obe=edu cage incm occp_re region_re/clparm VADJUST=NONE;
domain year year*sex;
estimate '교육수준과 비만율'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;

