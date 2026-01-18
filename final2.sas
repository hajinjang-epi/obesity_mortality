libname a "C:\Users\HajinJang\Documents\hn";
libname b "C:\Users\HajinJang\Documents\FINAL";

proc contents data=a.hn98_all;
run;
proc contents data=a.hn01_all;
run;
proc contents data=a.hn05_all;
run;
proc contents data=a.hn07_all;
run;
proc contents data=a.hn08_all;
run;
proc contents data=a.hn09_all;
run;
proc contents data=a.hn10_all;
run;
proc contents data=a.hn11_all;
run;
proc contents data=a.hn12_all;
run;
proc contents data=a.hn13_all;
run;
proc contents data=a.hn14_all;
run;
proc contents data=a.hn15_all;
run;
proc contents data=a.hn16_all;
run;
proc contents data=a.hn17_all;
run;
proc contents data=a.hn18_all;
run;

data hn98_05;
set a.hn98_all a.hn01_all a.hn05_all;
drop LS_type1 LS_type2 LS_type3 LS_type4;
run;


data B.FINAL2;
set hn98_05 a.hn07_all a.hn08_all a.hn09_all a.hn10_all a.hn11_all a.hn12_all a.hn13_all 
a.hn14_all a.hn15_all a.hn16_all a.hn17_all a.hn18_all;
drop LS_type1 LS_type2 LS_type3 LS_type4;
run;

DATA B.FINAL2;
SET B.FINAL2;

/*연령구간 변수(cage) 생성*/
      IF 19<=age<=29 THEN cage=2; ELSE IF 30<=age<=39 THEN cage=3;
ELSE IF 40<=age<=49 THEN cage=4; ELSE IF 50<=age<=59 THEN cage=5;
ELSE IF 60<=age<=69 THEN cage=6; ELSE IF 70<=age THEN cage=7;

/*성인 비만 유병여부 변수(OBE) 생성*/
IF age>=19 & ((year in (1998,2001) & HS_mens^=3) or (year=2005 & HE_mens^=3)) THEN do;
   IF HE_ht^=. & HE_wt^=. THEN HE_BMI = HE_wt / ((HE_ht/100)**2);
   IF HE_BMI^=. THEN OBE = (HE_BMI>=25);
END; 
IF age>=19 & 2007<=year<=2016 & HE_obe in (1,2,3) THEN OBE = (HE_obe=3);
IF age>=19 & 2017<=year<=2018 & HE_obe in (1,2,3,4,5,6) THEN OBE=(HE_obe in (4,5,6));

/* bmi 극단치 제거*/
if HE_BMI<=10 or HE_BMI>=50 then delete;

/*1)연도별 가중치 변수명 통일(wt_pool_1), 2)통합가중치 변수(wt_pool_2) 생성*/ 
IF 1998<=year<=2001 THEN do; 
   wt_pool_1 = wt_ex;    wt_pool_2 = wt_ex_t;
end;
IF 2005<=year<=2009 THEN do; 
   wt_pool_1 = wt_ex;    wt_pool_2 = wt_ex; 
end;
IF 2010<=year<=2018 THEN do; 
   wt_pool_1 = wt_itvex;  wt_pool_2 = wt_itvex;
end;


/*교육수준 3cat (edu_2)*/
if year in (1998,2001) & educ in (0,1,2,3,4,5,6) then do;
if educ in (0,1,2,3) then edu_2=1;
else if educ=4 then edu_2=2;
else if educ in (5,6) then edu_2=3;
end;
if year=2005 & educ in (0,1,2,3,4,5,6) & graduat in (1,2,3,4,5,8) then do;
if educ in (0,1,2,3) & graduat in (1,2,3,4,5,8) then edu_2=1;
else if educ=4 & graduat in (2,3,4,5) then edu_2=1;
else if educ=4 & graduat=1 then edu_2=2;
else if educ in (5,6) & graduat in (1,2,3,4,5) then edu_2=3;
end;
if year in (2007:2009) & educ in (1,2,3,4,5,6,7,8,9) & graduat in (1,2,3,4,8) then do;
if educ in (1,2,3,4,5) & graduat in (1,2,3,4,8) then edu_2=1;
else if educ=6 & graduat in (2,3,4) then edu_2=1;
else if educ=6 & graduat=1 then edu_2=2;
else if educ in (7,8,9) & graduat in (1,2,3,4) then edu_2=3;
end;
if year in (2010:2018) & educ in (1,2,3,4,5,6,7,8,88) & graduat in (1,2,3,4,8) then do;
if educ in (1,2,3,4) & graduat in (1,2,3,4,8) then edu_2=1;
else if educ=5 & graduat in (2,3,4) then edu_2=1;
else if educ=5 & graduat=1 then edu_2=2;
else if educ in (6,7,8) & graduat in (1,2,3,4) then edu_2=3;
end;

/*교육수준(edu)
IF age>=19 & year in (1998,2001) & educ in (0:6) THEN do; 
   if 0<=educ<=2 then edu=1;
   else IF educ=3 then edu=2;
   else IF educ=4 then edu=3;
   else IF 5<=educ<=6 then edu=4;
end;*/


/*직업(occp_2)*/
IF age>=15 & year in (1998,2001,2005) AND JOB_T IN (1:5) THEN do; 
   if job_t in (1,2) then occp_2=1;
   else IF job_t=3 then occp_2=2;
   else IF job_t=4 then occp_2=3;
   else IF job_t=5 then occp_2=4;
  end;
IF age>=15 & year in (2007:2018) AND OCCP IN (1:6) THEN do; 
if occp in (1,2) then occp_2=1;
ELSE if occp=3  then occp_2=2;
ELSE if occp=4 then occp_2=3;
ELSE if occp in (5,6) then occp_2=4;
end;
/*직업 (occp_re: 주부, 학생 등 포함)
data b.final2;
SET b.final2;
IF age>=15 & year in (1998,2001,2005) & job^=6 THEN do; 
   if job_t in (1,2) then occp_re=1;
   else IF job_t=3 then occp_re=2;
   else IF job_t=4 then occp_re=3;
   else IF job_t=5 then occp_re=4;
   else IF job_t in (7,8,77) then occp_re=5;
  end;
IF age>=15 & year in (2007:2018) THEN do; 
if occp in (1,2) then occp_re=1;
if occp=3  then occp_re=2;
if occp=4 then occp_re=3;
if occp in (5,6) then occp_re=4;
if occp=7  then occp_re=5;
end;
run; */

/*지역(region_2)*/
if year=1998 AND REGION^=. then do;
if region=1 then region_2=1; /*서울*/
else if region in (2:6) then region_2=2; /*광역시*/
else if region in (8:16) & town_t=1 then region_2=3; /*동 지역*/
else if region in (8:16) & town_t=2 then region_2=4; /*읍면 지역*/
end;
if year in (2001:2015) AND REGION^=. then do;
if region=1 then region_2=1; /*서울*/
else if region in (2:7) then region_2=2; /*광역시*/
else if region in (8:16) & town_t=1 then region_2=3; /*동 지역*/
else if region in (8:16) & town_t=2 then region_2=4; /*읍면 지역*/
end;
if year in (2016:2018) AND REGION^=. then do;
if region=1 then region_2=1; /*서울*/
else if region in (2:7) then region_2=2; /*광역시*/
else if region in (8:17) & town_t=1 then region_2=3; /* 동 지역*/
else if region in (8:17) & town_t=2 then region_2=4; /*읍면 지역*/
end;
/*지역(region_re)
DATA B.FINAL2;
SET B.FINAL2;
if year in (1998:2015) then do;
if region in (1,4,8,9) then region_re=1;
if region in (2,3,7,14,15) then region_re=2;
if region in (5,12,13) then region_re=3;
if region in (6,10,11) then region_re=4;
if region=16 then region_re=5;
end;
if year in (2016:2018) then do;
if region in (1,4,9,10) then region_re=1;
if region in (2,3,7,15,16) then region_re=2;
if region in (5,13,14) then region_re=3;
if region in (6,8,11,12) then region_re=4;
if region=17 then region_re=5;
end;*/

/*출생코호트(birthcohort)*/
birthyear=year-age;
if 1950<=birthyear<1960 then birthcohort=1;
else if 1960<=birthyear<1970 then birthcohort=2;
else if 1970<=birthyear<1980 then birthcohort=3;

/*복부비만 변수(ab_obe)& 극단치제거*/
if age>=19 & sex=1 & HE_WC in (40:120) then ab_obe=(he_wc>=90);
else if age>=19 & sex=2 & HE_WC in (40:120) then ab_obe=(he_wc>=85);

/*복부비만, 비만 동시유병 변수(both_obe)*/
if obe^=. and ab_obe^=. then do;
if obe=1 & ab_obe=1 then both_obe=1;  /*둘다 해당*/
if obe=1 & ab_obe=0 then both_obe=2; /*bmi비만만 해당*/
if obe=0 & ab_obe=1 then both_obe=3; /*복부비만만 해당*/
if obe=0 & ab_obe=0 then both_obe=4; /*둘다 비해당*/
end;
/*both_obe -> binary dummy 추가(both_bin)*/
if both_obe^=. then do;
if both_obe=1 then both_bin=1;
else if both_obe in (2,3,4) then both_bin=0;
end;

/*기수(TERM)*/
IF YEAR=1998 THEN TERM=1;
ELSE IF YEAR=2001 THEN TERM=2;
ELSE IF YEAR=2005 THEN TERM=3;
ELSE IF YEAR IN (2007:2009) THEN TERM=4;
ELSE IF YEAR IN (2010:2012) THEN TERM=5;
ELSE IF YEAR IN (2013:2015) THEN TERM=6;
ELSE IF YEAR IN (2006:2018) THEN TERM=7;

/*기수별 BMI(TERMBMI_기수)*/
IF TERM=1 AND HE_BMI^=. THEN TERMBMI_1=HE_BMI;
ELSE IF TERM=2 AND HE_BMI^=. THEN TERMBMI_2=HE_BMI;
ELSE IF TERM=3 AND HE_BMI^=. THEN TERMBMI_3=HE_BMI;
ELSE IF TERM=4 AND HE_BMI^=. THEN TERMBMI_4=HE_BMI;
ELSE IF TERM=5 AND HE_BMI^=. THEN TERMBMI_5=HE_BMI;
ELSE IF TERM=6 AND HE_BMI^=. THEN TERMBMI_6=HE_BMI;
ELSE IF TERM=7 AND HE_BMI^=. THEN TERMBMI_7=HE_BMI;

/*기수별 WC(TERMWC_기수)*/
IF TERM=1 AND HE_WC^=. THEN TERMWC_1=HE_WC;
ELSE IF TERM=2 AND HE_WC^=. THEN TERMWC_2=HE_WC;
ELSE IF TERM=3 AND HE_WC^=. THEN TERMWC_3=HE_WC;
ELSE IF TERM=4 AND HE_WC^=. THEN TERMWC_4=HE_WC;
ELSE IF TERM=5 AND HE_WC^=. THEN TERMWC_5=HE_WC;
ELSE IF TERM=6 AND HE_WC^=. THEN TERMWC_6=HE_WC;
ELSE IF TERM=7 AND HE_WC^=. THEN TERMWC_7=HE_WC;

/*기수 기준 비만유병여부(TERM_OBE)*/
IF TERMBMI_1^=. THEN TERM_OBE=(TERMBMI_1>=25); 
ELSE IF TERMBMI_2^=. THEN TERM_OBE=(TERMBMI_2>=25); 
ELSE IF TERMBMI_3^=. THEN TERM_OBE=(TERMBMI_3>=25);
ELSE IF TERMBMI_4^=. THEN TERM_OBE=(TERMBMI_4>=25);
ELSE IF TERMBMI_5^=. THEN TERM_OBE=(TERMBMI_5>=25); 
ELSE IF TERMBMI_6^=. THEN TERM_OBE=(TERMBMI_6>=25); 
ELSE IF TERMBMI_7^=. THEN TERM_OBE=(TERMBMI_7>=25); 

/*기수 기준 복부비만 유병여부(TERM_ABOBE)*/
IF TERMWC_1^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_1>=90);
ELSE IF TERMWC_1^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_1>=85);
ELSE IF TERMWC_2^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_2>=90);
ELSE IF TERMWC_2^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_2>=85);
ELSE IF TERMWC_3^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_3>=90);
ELSE IF TERMWC_3^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_3>=85);
ELSE IF TERMWC_4^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_4>=90);
ELSE IF TERMWC_4^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_4>=85);
ELSE IF TERMWC_5^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_5>=90);
ELSE IF TERMWC_5^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_5>=85);
ELSE IF TERMWC_6^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_6>=90);
ELSE IF TERMWC_6^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_6>=85);
ELSE IF TERMWC_7^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_7>=90);
ELSE IF TERMWC_7^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_7>=85);

/*기수별 나이(TERMAGE_기수)*/
IF TERM=1 THEN TERMAGE_1=AGE;
ELSE IF TERM=2 THEN TERMAGE_2=AGE;
ELSE IF TERM=3 THEN TERMAGE_3=AGE;
ELSE IF TERM=4 THEN TERMAGE_4=AGE;
ELSE IF TERM=5 THEN TERMAGE_5=AGE;
ELSE IF TERM=6 THEN TERMAGE_6=AGE;
ELSE IF TERM=7 THEN TERMAGE_7=AGE;

/*기수별 BMI-성별 층화(MENBMI_기수, WOMENBMI_기수)*/
IF SEX=1 THEN DO;
IF TERMBMI_1^=. THEN MENBMI_1=TERMBMI_1;
ELSE IF TERMBMI_2^=. THEN MENBMI_2=TERMBMI_2;
ELSE IF TERMBMI_3^=. THEN MENBMI_3=TERMBMI_3;
ELSE IF TERMBMI_4^=. THEN MENBMI_4=TERMBMI_4;
ELSE IF TERMBMI_5^=. THEN MENBMI_5=TERMBMI_5;
ELSE IF TERMBMI_6^=. THEN MENBMI_6=TERMBMI_6;
ELSE IF TERMBMI_7^=. THEN MENBMI_7=TERMBMI_7;
END;
IF SEX=2 THEN DO;
IF TERMBMI_1^=. THEN WOMENBMI_1=TERMBMI_1;
ELSE IF TERMBMI_2^=. THEN WOMENBMI_2=TERMBMI_2;
ELSE IF TERMBMI_3^=. THEN WOMENBMI_3=TERMBMI_3;
ELSE IF TERMBMI_4^=. THEN WOMENBMI_4=TERMBMI_4;
ELSE IF TERMBMI_5^=. THEN WOMENBMI_5=TERMBMI_5;
ELSE IF TERMBMI_6^=. THEN WOMENBMI_6=TERMBMI_6;
ELSE IF TERMBMI_7^=. THEN WOMENBMI_7=TERMBMI_7;
END;

/*기수별 WC-성별 층화(MENWC_기수, WOMENWC_기수)*/
IF SEX=1 THEN DO;
IF TERMWC_1^=. THEN MENWC_1=TERMWC_1;
ELSE IF TERMWC_2^=. THEN MENWC_2=TERMWC_2;
ELSE IF TERMWC_3^=. THEN MENWC_3=TERMWC_3;
ELSE IF TERMWC_4^=. THEN MENWC_4=TERMWC_4;
ELSE IF TERMWC_5^=. THEN MENWC_5=TERMWC_5;
ELSE IF TERMWC_6^=. THEN MENWC_6=TERMWC_6;
ELSE IF TERMWC_7^=. THEN MENWC_7=TERMWC_7;
END;
IF SEX=2 THEN DO;
IF TERMWC_1^=. THEN WOMENWC_1=TERMWC_1;
ELSE IF TERMWC_2^=. THEN WOMENWC_2=TERMWC_2;
ELSE IF TERMWC_3^=. THEN WOMENWC_3=TERMWC_3;
ELSE IF TERMWC_4^=. THEN WOMENWC_4=TERMWC_4;
ELSE IF TERMWC_5^=. THEN WOMENWC_5=TERMWC_5;
ELSE IF TERMWC_6^=. THEN WOMENWC_6=TERMWC_6;
ELSE IF TERMWC_7^=. THEN WOMENWC_7=TERMWC_7;
END;
 
RUN;

/*BMI, WC MEAN & SD*/
PROC SURVEYMEANS data=B.FINAL2 NOMCAR;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
VAR menwc_1 menwc_2 menwc_3 menwc_4 menwc_5 menwc_6 menwc_7;
run;



/*------------------------------------------------- FIGURES & TABLES -------------------------------------------------*/

/*GRAPH1: DENSITY PLOT*/
title font='Times New Roman' 'BMI Distribution in Men';
proc sgplot data=B.FINAL2;
  density menbmi_4/ legendlabel='KNHANESⅣ (2007-2009)' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent ;
  density menbmi_5/ legendlabel='KNHANESⅤ (2010-2012)' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density menbmi_6/ legendlabel='KNHANESⅥ (2013-2015)' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;
  density menbmi_7/ legendlabel='KNHANESⅦ (2016-2018)' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
  xaxis label="BMI (kg/m2)" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
  yaxis label="Percent" labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
  footnote color=grey h=9pt font='Times New Roman' 'BMI: Body mass index';
  run;
  title font='Times New Roman' 'BMI Distribution in Women';
proc sgplot data=B.FINAL2;
  density WOMENBMI_4/ legendlabel='KNHANESⅣ (2007-2009)' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent;
  density WOMENBMI_5/ legendlabel='KNHANESⅤ (2010-2012)' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density WOMENBMI_6/ legendlabel='KNHANESⅥ (2013-2015)' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;
  density WOMENBMI_7/ legendlabel='KNHANESⅦ (2016-2018)' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
  xaxis label="BMI (kg/m2)" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
  yaxis label="Percent" labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
    footnote color=grey h=9pt font='Times New Roman' 'BMI: Body mass index';
run;

 title font='Times New Roman' 'WC Distribution in Men';
   footnote color=grey h=9pt font='Times New Roman' 'WC: Waist circumference';
proc sgplot data=B.FINAL2;
  density menWC_4/ legendlabel='KNHANESⅣ (2007-2009)' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent;
  density menWC_5/ legendlabel='KNHANESⅤ (2010-2012)' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density menWC_6/ legendlabel='KNHANESⅥ (2013-2015)' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;
  density menWC_7/ legendlabel='KNHANESⅦ (2016-2018)' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
  xaxis label="WC (cm)" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
  yaxis label="Percent" labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
 run;
   title font='Times New Roman' 'WC Distribution in Women';
    footnote color=grey h=9pt font='Times New Roman' 'WC: Waist circumference';
proc sgplot data=B.FINAL2;
  density womenWC_4/ legendlabel='KNHANESⅣ (2007-2009)' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent;
  density womenWC_5/ legendlabel='KNHANESⅤ (2010-2012)' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density womenWC_6/ legendlabel='KNHANESⅥ (2013-2015)' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;
  density womenWC_7/ legendlabel='KNHANESⅦ (2016-2018)' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
  xaxis label="WC (cm)" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
  yaxis label="Percent" labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
 run;

 proc means mean std median kurtosis skewness data=b.final2; var menwc_4 menwc_5 menwc_6 menwc_7 womenbmi_4 womenbmi_5
womenbmi_6 womenbmi_7 womenwc_4 womenwc_5 womenwc_6 womenwc_7; run;  


/*코호트 그래프*/
PROC SURVEYMEANS data=B.FINAL2 NOMCAR;
STRATA kstrata;
CLUSTER psu;
WEIGHT wt_pool_2;
DOMAIN SEX*BIRTHCOHORT*AGE;
VAR HE_BMI;
run;

DATA COHORT;
SET B.FINAL2;
IF BIRTHCOHORT=1 THEN DO;
MEN_11=(SEX=1 AND EDU=1); MEN_14=(SEX=1 AND EDU=4); WOMEN_11=(SEX=2 AND EDU=1); WOMEN_14=(SEX=2 AND EDU=4);END;
ELSE IF BIRTHCOHORT=2 THEN DO;
MEN_21=(SEX=1 AND EDU=1); MEN_24=(SEX=1 AND EDU=4); WOMEN_21=(SEX=2 AND EDU=1); WOMEN_24=(SEX=2 AND EDU=4);END;
ELSE IF BIRTHCOHORT=3 THEN DO;
MEN_31=(SEX=1 AND EDU=1); MEN_34=(SEX=1 AND EDU=4); WOMEN_31=(SEX=2 AND EDU=1); WOMEN_34=(SEX=2 AND EDU=4);END;
RUN;

PROC SURVEYMEANS data=COHORT NOMCAR;
STRATA kstrata;
CLUSTER psu;
WEIGHT wt_pool_2;
DOMAIN MEN_31*AGE MEN_34*AGE WOMEN_31*AGE WOMEN_34*AGE;
VAR HE_BMI;
run;

DATA B.COHORT_MEN;
INPUT COHORT AGE BMI;
CARDS;
1	39	23.676424
1	40	23.581382
1	41	23.980373
1	42	24.02612
1	43	24.412322
1	44	23.994466
1	45	23.525824
1	46	24.762692
1	47	23.979345
1	48	23.871439
1	49	24.368801
1	50	23.693253
1	51	24.259664
1	52	24.45712
1	53	24.188706
1	54	24.407433
1	55	24.0366
1	56	24.211521
1	57	24.315429
1	58	24.549696
1	59	24.039962
1	60	24.47966
1	61	24.271757
1	62	24.022135
1	63	24.233689
1	64	24.261761
1	65	23.7614
1	66	24.233717
1	67	24.049341
1	68	24.126458
2	29	22.930081
2	30	22.889085
2	31	22.501218
2	32	23.973848
2	33	23.699514
2	34	23.662907
2	35	23.529223
2	36	23.980028
2	37	23.830218
2	38	24.210167
2	39	24.319638
2	40	24.340779
2	41	24.862239
2	42	24.532515
2	43	24.214595
2	44	24.532095
2	45	24.080598
2	46	24.567554
2	47	24.387846
2	48	24.441451
2	49	24.527159
2	50	24.741222
2	51	24.658104
2	52	24.282277
2	53	24.582932
2	54	24.513011
2	55	24.374224
2	56	24.439965
2	57	23.73768
2	58	24.76912
3	19	21.468231
3	20	23.012571
3	21	22.158515
3	22	22.702667
3	23	21.814206
3	24	22.943551
3	25	22.59915
3	26	23.427498
3	27	23.185801
3	28	23.69136
3	29	23.990127
3	30	24.178292
3	31	24.167522
3	32	24.547807
3	33	24.29022
3	34	24.611166
3	35	24.363158
3	36	24.177014
3	37	24.601408
3	38	24.433961
3	39	24.747511
3	40	24.781028
3	41	25.01334
3	42	25.134793
3	43	25.171253
3	44	24.829904
3	45	24.908463
3	46	24.437828
3	47	25.026863
3	48	25.134691
;
RUN;

DATA B.COHORT_WOMEN;
INPUT COHORT AGE BMI;
CARDS;
1	39	23.004271
1	40	23.347367
1	41	23.174774
1	42	23.828119
1	43	23.886501
1	44	23.774725
1	45	24.29954
1	46	23.974271
1	47	23.896011
1	48	23.875507
1	49	23.822386
1	50	23.831663
1	51	24.038602
1	52	24.157741
1	53	24.331936
1	54	24.322797
1	55	24.1102
1	56	24.095675
1	57	24.401373
1	58	24.192817
1	59	24.291174
1	60	24.305264
1	61	24.334207
1	62	24.655368
1	63	24.427518
1	64	24.504787
1	65	24.571091
1	66	24.638852
1	67	24.985116
1	68	24.056784
2	29	21.719717
2	30	22.301964
2	31	22.173549
2	32	22.304952
2	33	22.826843
2	34	22.357152
2	35	22.715765
2	36	23.200134
2	37	23.085479
2	38	22.863486
2	39	22.869778
2	40	23.417211
2	41	23.078171
2	42	23.579011
2	43	23.578245
2	44	23.446942
2	45	23.708718
2	46	23.700501
2	47	23.618559
2	48	23.72346
2	49	23.916868
2	50	23.966459
2	51	23.855402
2	52	23.548944
2	53	23.73963
2	54	23.941073
2	55	23.923196
2	56	23.900477
2	57	23.719509
2	58	24.106516
3	19	20.836816
3	20	20.899607
3	21	20.675197
3	22	20.711968
3	23	21.143505
3	24	20.703305
3	25	21.081047
3	26	21.734339
3	27	21.39253
3	28	22.419133
3	29	22.329908
3	30	22.036202
3	31	21.679823
3	32	22.112671
3	33	22.376044
3	34	22.475019
3	35	22.63846
3	36	22.692084
3	37	22.617421
3	38	22.71381
3	39	23.069754
3	40	22.798125
3	41	23.181945
3	42	22.90661
3	43	22.937239
3	44	23.403704
3	45	23.181119
3	46	23.481898
3	47	23.442015
3	48	23.24273
;
RUN;

proc sort data=B.COHORT_WOMEN;
by COHORT;
run;

data B.COHORT_MEN;
SET B.COHORT_MEN;
if cohort=1 then bmi_1= BMI;
else if cohort=2 then bmi_2= BMI;
else if cohort=3 then bmi_3= BMI;
run;
data B.COHORT_WOMEN;
SET B.COHORT_WOMEN;
if cohort=1 then bmi_4= BMI;
else if cohort=2 then bmi_5= BMI;
else if cohort=3 then bmi_6= BMI;
run;

proc surveyfreq data=b.final2;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
table sex*birthcohort*edu;
run;

title  font='Times New Roman' 'Trends of BMI in Men Stratified by Birth Cohorts and Ages';
footnote;
proc sgplot data=B.cohort_men;
  series x=AGE y=BMI_1/ legendlabel='Birth in 1950-1959' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=BMI_2/ legendlabel='Birth in 1960-1969' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  series x=AGE y=BMI_3/ legendlabel='Birth in 1970-1979' lineattrs=(PATTERN=SOLID COLOR=lightgreen) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(19 to 70 by 2) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=20 max=27 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

title font='Times New Roman' 'Trends of BMI in Women Stratified by Birth Cohorts and Ages';
footnote;
proc sgplot data=B.cohort_women;
  series x=AGE y=BMI_4/ legendlabel='Birth in 1950-1959' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=BMI_5/ legendlabel='Birth in 1960-1969' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  series x=AGE y=BMI_6/ legendlabel='Birth in 1970-1979' lineattrs=(PATTERN=SOLID COLOR=lightgreen) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(19 to 70 by 2) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=20 max=27 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;


DATA B.COHORT_EDU;
SET B.COHORT_EDU;
IF SEX=1 AND EDU=1 AND COHORT=1 THEN M11=BMI;
ELSE IF SEX=1 AND EDU=4 AND COHORT=1 THEN M14=BMI;
ELSE IF SEX=2 AND EDU=1 AND COHORT=1 THEN W11=BMI;
ELSE IF SEX=2 AND EDU=4 AND COHORT=1 THEN W14=BMI;
ELSE IF SEX=1 AND EDU=1 AND COHORT=2 THEN M21=BMI;
ELSE IF SEX=1 AND EDU=4 AND COHORT=2 THEN M24=BMI;
ELSE IF SEX=2 AND EDU=1 AND COHORT=2 THEN W21=BMI;
ELSE IF SEX=2 AND EDU=4 AND COHORT=2 THEN W24=BMI;
ELSE IF SEX=1 AND EDU=1 AND COHORT=3 THEN M31=BMI;
ELSE IF SEX=1 AND EDU=4 AND COHORT=3 THEN M34=BMI;
ELSE IF SEX=2 AND EDU=1 AND COHORT=3 THEN W31=BMI;
ELSE IF SEX=2 AND EDU=4 AND COHORT=3 THEN W34=BMI;
RUN;

title font='Times New Roman' 'Trends of BMI in Men Stratified by Birth Cohorts, Education Levels and Ages                    (Birth in 1950-1959)' ;
footnote;
proc sgplot data=B.cohort_edu;
  series x=AGE y=M11/ legendlabel='Under Elementary Graduate' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=M14/ legendlabel='Over college Graduate' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(37 to 70 by 1) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=14 max=28 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;
title font='Times New Roman' 'Trends of BMI in Men Stratified by Birth Cohorts, Education Levels and Ages                    (Birth in 1960-1969)' ;
footnote;
proc sgplot data=B.cohort_edu;
  series x=AGE y=M21/ legendlabel='Under Elementary Graduate' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=M24/ legendlabel='Over college Graduate' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(27 to 60 by 1) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=14 max=28 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;
title font='Times New Roman' 'Trends of BMI in Men Stratified by Birth Cohorts, Education Levels and Ages                    (Birth in 1970-1979)' ;
footnote;
proc sgplot data=B.cohort_edu;
  series x=AGE y=M31/ legendlabel='Under Elementary Graduate' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=M34/ legendlabel='Over college Graduate' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(17 to 50 by 1) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=14 max=28 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;


title font='Times New Roman' 'Trends of BMI in Women Stratified by Birth Cohorts, Education Levels and Ages                    (Birth in 1950-1959)' ;
footnote;
proc sgplot data=B.cohort_edu;
  series x=AGE y=W11/ legendlabel='Under Elementary Graduate' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=W14/ legendlabel='Over college Graduate' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(37 to 70 by 1) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=14 max=33 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;
title font='Times New Roman' 'Trends of BMI in Women Stratified by Birth Cohorts, Education Levels and Ages                    (Birth in 1960-1969)';
footnote;
proc sgplot data=B.cohort_edu;
  series x=AGE y=W21/ legendlabel='Under Elementary Graduate' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=W24/ legendlabel='Over college Graduate' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(27 to 60 by 1) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=14 max=33 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;
title font='Times New Roman' 'Trends of BMI in Women Stratified by Birth Cohorts, Education Levels and Ages                    (Birth in 1970-1979)' ;
footnote;
proc sgplot data=B.cohort_edu;
  series x=AGE y=W31/ legendlabel='Under Elementary Graduate' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=AGE y=W34/ legendlabel='Over college Graduate' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Age" values=(17 to 50 by 1) LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Mean BMI (kg/m2)" min=14 max=33 labelpos=top LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;



/*GRAPH2: 성별별 차수별 비만, 복부비만 분포 꺾은선 추이그래프(linear graph following research years)

proc surveyfreq data=B.FINAL2 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*term*term_obe/row chisq;
run;
proc surveyfreq data=B.FINAL2 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*term*term_ABobe/row chisq;
run;

data B.FINAL2;
input TERM termNAME $ obe_freq abobe_freq;
cards;
1 KNHANESⅠ 24.8424 19.2684
2 KNHANESⅡ 31.2921 22.2122
3 KNHANESⅢ 34.9212 24.4746
4 KNHANESⅣ 29.7489 20.2221
5 KNHANESⅤ 30.7652 20.8661
6 KNHANESⅥ 32.6990 22.6938
7 KNHANESⅦ 36.0164 27.4865
;
RUN;

data B.FINAL2;
input TERM termNAME $ obe_freq abobe_freq;
cards;
1 KNHANESⅠ 25.2653 21.6014
2 KNHANESⅡ 27.2108 23.1306
3 KNHANESⅢ 27.8778 23.1357
4 KNHANESⅣ 22.4867 20.1982
5 KNHANESⅤ 24.4682 20.2865
6 KNHANESⅥ 23.4422 19.0907
7 KNHANESⅦ 24.9479 21.0266
;
RUN;

  title 'Overall Obesity and Abdominal Obesity Trends in Men';
proc sgplot data=B.FINAL_GRAPH2_MEN;
  series x=term y=OBE_FREQ/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=term y=ABOBE_FREQ/ legendlabel='Abdominal obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1;
XAXIS LABEL="KNHANES (Ⅰ~Ⅶ)" ;
yaxis label="Percent" labelpos=top MAX=40;
  run;
    title 'Overall Obesity and Abdominal Obesity Trends in Women';
proc sgplot data=B.FINAL_GRAPH2_WOMEN;
  series x=term y=OBE_FREQ/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=term y=ABOBE_FREQ/ legendlabel='Abdominal obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1;
XAXIS LABEL="KNHANES (Ⅰ~Ⅶ)" ;
yaxis label="Percent" labelpos=top MAX=35;
  run;
  */

DATA B.GRAPH22_MEN;
INPUT YEAR $ OVERALL CENTRAL;
CARDS;
1998	24.8424	21.7328
2001	31.2921	20.7087
2005	34.9212	26.6514
2007	36.5794	26.0064
2008	35.6356	24.531
2009	36.2069	25.9586
2010	36.4635	25.3845
2011	35.1812	28.9576
2012	36.0541	23.9958
2013	37.5702	23.9122
2014	37.7323	23.7663
2015	39.5754	34.1893
2016	41.7856	32.8668
2017	41.1482	33.9729
2018	41.9251	33.6055
;
run;

DATA B.GRAPH22_WOMEN;
INPUT YEAR $ OVERALL CENTRAL;
CARDS;
1998	25.2653	19.3943
2001	27.2108	21.7912
2005	27.8778	24.602
2007	27.7563	28.0662
2008	26.4688	26.2183
2009	27.6332	21.9364
2010	26.3819	23.9217
2011	28.6467	27.3948
2012	29.6279	24.8064
2013	27.4887	17.9037
2014	25.341	16.9969
2015	28.7614	29.5832
2016	29.1917	30.8944
2017	28.3593	22.1621
2018	28.0825	20.9924
;
RUN;

DATA B.GRAPH2_MEN;
INPUT YEAR $ OVERALL CENTRAL;
CARDS;
1998	24.74	22.09
2001	31.25	21.99
2005	34.69	26.64
2007	36.25	25.69
2008	35.34	24.29
2009	35.84	26.38
2010	36.38	24.65
2011	35.12	27.44
2012	36.28	23.38
2013	37.66	23.45
2014	37.78	24.01
2015	39.7	33.33
2016	42.26	32.84
2017	41.63	33.13
2018	42.76	35.28
;
RUN;
DATA B.GRAPH2_WOMEN;
INPUT YEAR $ OVERALL CENTRAL;
CARDS;
1998	26.18	20.48
2001	27.52	22.21
2005	27.27	22.4
2007	26.29	25.26
2008	25.19	24.95
2009	26.02	19.39
2010	24.78	21.35
2011	27.09	24.37
2012	27.9	21.36
2013	25.06	15.86
2014	23.25	15.09
2015	25.92	25.06
2016	26.38	28.7
2017	25.57	17.31
2018	25.54	16.63
;
RUN;

/*연령표준화 안하고 연도별로 비만율 본 것*/
title font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Men' ;
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥90 cm";
proc sgplot data=B.GRAPH22_MEN;
  series x=YEAR y=OVERALL/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=YEAR y=CENTRAL/ legendlabel='Central obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Year" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

title font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Women' ;
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥85 cm";
proc sgplot data=B.GRAPH22_WOMEN;
  series x=YEAR y=OVERALL/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=YEAR y=CENTRAL/ legendlabel='Central obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Year" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

/*연령표준화하고 연도별로 비만율 본 것*/
title font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Men' ;
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥90 cm";
proc sgplot data=B.GRAPH2_MEN;
  series x=YEAR y=OVERALL/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=YEAR y=CENTRAL/ legendlabel='Central obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Year" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

title  font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Women';
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥85 cm";
proc sgplot data=B.GRAPH2_WOMEN;
  series x=YEAR y=OVERALL/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=YEAR y=CENTRAL/ legendlabel='Central obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="Year" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;


DATA B.GRAPH2_TERM_MEN;
INPUT TERM $ OVERALL CENTRAL;
CARDS;
Ⅰ(1998)	24.74	22.09
Ⅱ(2001)	31.25	21.99
Ⅲ(2005)	34.69	26.64
Ⅳ(07-09)	35.81	25.46
Ⅴ(10-12)	35.91	25.27
Ⅵ(13-15)	38.4	26.68
Ⅶ(16-18)	42.2	33.76
;
RUN;
DATA B.GRAPH2_TERM_WOMEN;
INPUT TERM OVERALL CENTRAL;
CARDS;
1	26.18	20.48
2	27.52	22.21
3	27.27	22.4
4	25.8	23.39
5	26.59	22.34
6	24.74	18.65
7	25.83	21.13
;
RUN;

title font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Men' ;
footnote justify=center font='Times New Roman' color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥90 cm";
proc sgplot data=B.GRAPH2_TERM_MEN;
  series x=TERM y=OVERALL/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=TERM y=CENTRAL/ legendlabel='Central obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="KNHANES wave" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") values=("Ⅰ(1998)" "Ⅱ(2001)" "Ⅲ(2005)" "Ⅳ(2007-2009)" "Ⅴ(2010-2012)" "Ⅵ(2013-2015)" "Ⅶ(2016-2018)");
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

title  font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Women';
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥85 cm";
proc sgplot data=B.GRAPH2_TERM_WOMEN;
  series x=TERM y=OVERALL/ legendlabel='Overall obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=TERM y=CENTRAL/ legendlabel='Central obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="KNHANES wave" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

/*연령표준화, 기수별 추이그래프*/
DATA B.TERMTREND_MEN;
INPUT TERM OVERALL CENTRAL;
CARDS;
1	24.74	22.09
2	31.25	21.99
3	34.69	26.64
4	35.81	25.46
5	35.91	25.27
6	38.4	26.68
7	42.2	33.76
;
RUN;
DATA B.TERMTREND_WOMEN;
INPUT TERM OVERALL CENTRAL;
CARDS;
1	26.18	20.48
2	27.52	22.21
3	27.27	22.4
4	25.8	23.39
5	26.59	22.34
6	24.74	18.65
7	25.83	21.13
;
RUN;

title  font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Men';
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥85 cm";
proc sgplot data=B.TERMTREND_MEN;
  series x=TERM y=OVERALL/ legendlabel='Overall Obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=TERM y=CENTRAL/ legendlabel='Central Obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="KNHANES wave" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") VALUES=("Ⅰ(1998)" "Ⅱ(2001)" "Ⅲ(2005)"
"Ⅳ(07-09)" "Ⅴ(10-12)" "Ⅵ(13-15)" "Ⅶ(16-18)") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;

title  font='Times New Roman' 'Overall Obesity and Central Obesity Trends in Women';
footnote justify=center font='Times New Roman'color=grey h=9pt "Overall obesity: BMI≥25 kg/m2      Central obesity: WC≥85 cm";
proc sgplot data=B.TERMTREND_WOMEN;
  series x=TERM y=OVERALL/ legendlabel='Overall Obesity' lineattrs=(PATTERN=SOLID COLOR=lightblue) ;
  series x=TERM y=CENTRAL/ legendlabel='Central Obesity' lineattrs=(PATTERN=SOLID COLOR=lightred) ;
  keylegend / location=inside position=topright across=1 titleattrs=(family="Times New Roman") valueattrs=(family="Times New Roman");
XAXIS LABEL="KNHANES wave" LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman") VALUES=("Ⅰ(1998)" "Ⅱ(2001)" "Ⅲ(2005)"
"Ⅳ(07-09)" "Ⅴ(10-12)" "Ⅵ(13-15)" "Ⅶ(16-18)") ;
yaxis label="Percent" labelpos=top MIN=10 MAX=50 LABELATTRS=(FAMILY="Times New Roman") valueattrs=(FAMILY="Times New Roman");
run;


/*TABLE1: 성별별 차수별 인구사회학적 요인에 따른 비만과 복부비만 distribution(%) (cage, incm, edu, region_2, occp_2)*/

  /*연령표준화*/
proc surveyreg data=B.FINAL2 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
class cage;
domain SEX*TERM;
model AB_obe=cage /noint vadjust=NONE;
estimate '복부비만율'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;

proc surveyfreq data=B.FINAL2 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*TERM*edu_2*TERM_abOBE/row chisq;
run;


/*TABLE2: 성별별 차수별 인구학적 요인에 따른 OR*/  

proc surveylogistic data=B.FINAL2 nomcar;
strata kstrata;
cluster psu;
weight wt_pool_2;
class cage(ref="2") incm(ref="1") edu_2(ref="1") region_2(ref="1") occp_2(ref="1") ;
model TERM_OBE(EVENT='1')=CAGE INCM EDU_2 REGION_2 OCCP_2/VADJUST=NONE;
domain SEX*TERM;
estimate 'OBESITY'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;

proc surveylogistic data=B.FINAL1 nomcar;
strata kstrata;
cluster psu;
weight wt_pool_2;
class cage(ref="2") incm(ref="1") edu(ref="1") region_2(ref="1") occp_2(ref="1") ;
model TERM_ABOBE(EVENT='1')=CAGE INCM EDU REGION_2 OCCP_2/VADJUST=NONE;
domain SEX*TERM;
estimate 'ABDOMINAL OBESITY'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;


/*Supplementary-both*/

proc surveyfreq data=B.FINAL2 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*term*both_bin/row chisq;
run;

proc surveyfreq data=B.FINAL2 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*TERM*edu*TERM_OBE/row chisq;
run;

