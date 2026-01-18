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


data b.final;
set hn98_05 a.hn07_all a.hn08_all a.hn09_all a.hn10_all a.hn11_all a.hn12_all a.hn13_all 
a.hn14_all a.hn15_all a.hn16_all a.hn17_all a.hn18_all;
drop LS_type1 LS_type2 LS_type3 LS_type4;
run;

DATA b.final;
SET b.final;

/*연령구간 변수(cage) 생성*/
      IF 19<=age<=29 THEN cage=2; ELSE IF 30<=age<=39 THEN cage=3;
ELSE IF 40<=age<=49 THEN cage=4; ELSE IF 50<=age<=59 THEN cage=5;
ELSE IF 60<=age<=69 THEN cage=6; ELSE IF 70<=age THEN cage=7;

/*성인 비만 유병여부 변수(OBE) 생성*/
IF age>=19 & ((year in (1998,2001) & HS_mens^=3) or (year=2005 & HE_mens^=3)) THEN do;
   IF HE_ht^=. & HE_wt^=. THEN HE_BMI = HE_wt / ((HE_ht/100)**2);
   IF HE_BMI^=. THEN OBE = (HE_BMI>=25);
END; 
IF age>=19 & 2007<=year<=2018 & HE_obe in (1,2,3) THEN OBE = (HE_obe=3);

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
RUN;

/*교육수준*/
data b.final;
SET b.final;
IF age>=19 & year in (1998,2001) THEN do; 
   if 0<=educ<=2 then edu=1;
   else IF educ=3 then edu=2;
   else IF educ=4 then edu=3;
   else IF 5<=educ<=6 then edu=4;
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
run;

/*직업 job_t에서 occp_re로 코딩*/
data b.final;
SET b.final;
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
run; 

/*지역(region_re)*/
data b.final;
SET b.final;
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
end;
/* 지역 재분류(region_2)*/
if year=1998 then do;
if region=1 then region_2=1;
else if region in (2:6) then region_2=2;
else if region in (8:16) & town_t=1 then region_2=3; /*동 지역*/
else if region in (8:16) & town_t=2 then region_2=4; /*읍면 지역*/
end;
if year in (2001:2015) then do;
if region=1 then region_2=1;
else if region in (2:7) then region_2=2;
else if region in (8:16) & town_t=1 then region_2=3; /*동 지역*/
else if region in (8:16) & town_t=2 then region_2=4; /*읍면 지역*/
end;
if year in (2016:2018) then do;
if region=1 then region_2=1;
else if region in (2:7) then region_2=2;
else if region in (8:17) & town_t=1 then region_2=3; /* 동 지역*/
else if region in (8:17) & town_t=2 then region_2=4; /*읍면 지역*/
end;
run;

/*출생코호트*/
data b.final;
SET b.final;
birthyear=year-age;
if birthyear<=1940 then birthcohort_10=1;
else if 1940<birthyear<=1950 then birthcohort_10=2;
else if 1950<birthyear<=1960 then birthcohort_10=3;
else if 1960<birthyear<=1970 then birthcohort_10=4;
else if 1970<birthyear<=1980 then birthcohort_10=5;
else if 1980<birthyear<=1990 then birthcohort_10=6;
else if 1990<birthyear<=2000 then birthcohort_10=7;
run;

/*복부비만 변수(ab_obe)-극단치 제거 포함되어 있음*/
data b.final;
SET b.final;
if age>=19 & sex=1 & HE_WC in (40:120) then ab_obe=(he_wc>=90);
else if age>=19 & sex=2 & HE_WC in (40:120) then ab_obe=(he_wc>=85);
run;

/*복부비만, 비만 동시유병 변수(both_obe)
data b.final;
SET b.final;
if obe^=. and ab_obe^=. then do;
if obe=1 & ab_obe=1 then both_obe=1;             *둘다 해당;
if obe=1 & ab_obe=0 then both_obe=2;     *bmi비만만 해당;
if obe=0 & ab_obe=1 then both_obe=3;     *복부비만만 해당;
if obe=0 & ab_obe=0 then both_obe=4;     *둘다 비해당;
end;
run;*/

/* bmi 극단치 제거-density plot 그릴때 사용*/
data b.final;
SET b.final;
if HE_BMI<=10 or HE_BMI>=50 then delete;
run;


/*차수별로 나누기*/
DATA B.FINAL;
SET B.FINAL;
IF YEAR=1998 THEN TERM=1;
ELSE IF YEAR=2001 THEN TERM=2;
ELSE IF YEAR=2005 THEN TERM=3;
ELSE IF YEAR IN (2007:2009) THEN TERM=4;
ELSE IF YEAR IN (2010:2012) THEN TERM=5;
ELSE IF YEAR IN (2013:2015) THEN TERM=6;
ELSE IF YEAR IN (2006:2018) THEN TERM=7;
RUN; 

/*직업 코딩 다시하는 것 FINAL1에서 함, FINAL에는 안되어있음*/
DATA B.FINAL1;
SET B.FINAL1;
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
run; 

/*차수별 변수 만들기-BMI, WC, OBE, AB_OBE, AGE*/
DATA B.FINAL1;
SET B.FINAL;
IF TERM=1 AND HE_BMI^=. THEN TERMBMI_1=HE_BMI;
ELSE IF TERM=2 AND HE_BMI^=. THEN TERMBMI_2=HE_BMI;
ELSE IF TERM=3 AND HE_BMI^=. THEN TERMBMI_3=HE_BMI;
ELSE IF TERM=4 AND HE_BMI^=. THEN TERMBMI_4=HE_BMI;
ELSE IF TERM=5 AND HE_BMI^=. THEN TERMBMI_5=HE_BMI;
ELSE IF TERM=6 AND HE_BMI^=. THEN TERMBMI_6=HE_BMI;
ELSE IF TERM=7 AND HE_BMI^=. THEN TERMBMI_7=HE_BMI;

IF TERM=1 AND HE_WC^=. THEN TERMWC_1=HE_WC;
ELSE IF TERM=2 AND HE_WC^=. THEN TERMWC_2=HE_WC;
ELSE IF TERM=3 AND HE_WC^=. THEN TERMWC_3=HE_WC;
ELSE IF TERM=4 AND HE_WC^=. THEN TERMWC_4=HE_WC;
ELSE IF TERM=5 AND HE_WC^=. THEN TERMWC_5=HE_WC;
ELSE IF TERM=6 AND HE_WC^=. THEN TERMWC_6=HE_WC;
ELSE IF TERM=7 AND HE_WC^=. THEN TERMWC_7=HE_WC;
RUN;


DATA B.FINAL1;
SET B.FINAL1;
IF TERMBMI_1^=. THEN TERM_OBE=(TERMBMI_1>=25); 
ELSE IF TERMBMI_2^=. THEN TERM_OBE=(TERMBMI_2>=25); 
ELSE IF TERMBMI_3^=. THEN TERM_OBE=(TERMBMI_3>=25);
ELSE IF TERMBMI_4^=. THEN TERM_OBE=(TERMBMI_4>=25);
ELSE IF TERMBMI_5^=. THEN TERM_OBE=(TERMBMI_5>=25); 
ELSE IF TERMBMI_6^=. THEN TERM_OBE=(TERMBMI_6>=25); 
ELSE IF TERMBMI_7^=. THEN TERM_OBE=(TERMBMI_7>=25); 


IF TERMWC_1^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_1>=90);
ELSE IF TERMWC_1^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_1>=85);
IF TERMWC_2^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_2>=90);
ELSE IF TERMWC_2^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_2>=85);
IF TERMWC_3^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_3>=90);
ELSE IF TERMWC_3^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_3>=85);
IF TERMWC_4^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_4>=90);
ELSE IF TERMWC_4^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_4>=85);
IF TERMWC_5^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_5>=90);
ELSE IF TERMWC_5^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_5>=85);
IF TERMWC_6^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_6>=90);
ELSE IF TERMWC_6^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_6>=85);
IF TERMWC_7^=. AND SEX=1 THEN TERM_ABOBE=(TERMWC_7>=90);
ELSE IF TERMWC_7^=. AND SEX=2 THEN TERM_ABOBE=(TERMWC_7>=85);

IF TERM=4 THEN TERMAGE_4=AGE;
ELSE IF TERM=5 THEN TERMAGE_5=AGE;
ELSE IF TERM=6 THEN TERMAGE_6=AGE;
ELSE IF TERM=7 THEN TERMAGE_7=AGE;
RUN;


/*출생코호트 50-80년생으로 다시 만들기*/




/*--------------------------------------------------------------GRAPHS & TABLES--------------------------------------------------------------*/


/*graph1: 성별별 차수별 BMI, WC 분포그래프(density graph)*/
/*B.FINAL_GRAPH1: 그래프에서 사용할 변수만 빼서 만든 크기 작은 파일*/
data B.FINAL_GRAPH1;
set B.FINAL1;
keep id TERM SEX term_obe term_abobe TERMBMI_1 TERMBMI_2 TERMBMI_3 TERMBMI_4 TERMBMI_5 TERMBMI_6 TERMBMI_7 TERMWC_1 TERMWC_2 TERMWC_3 TERMWC_4 TERMWC_5 TERMWC_6 TERMWC_7;
RUN;

data B.FINAL_GRAPH1;
SET B.FINAL_GRAPH1;
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
run;

data B.FINAL_GRAPH1;
SET B.FINAL_GRAPH1;
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


/*BMI, WC 평균 표준오차 구하기 위해 본 데이터에 여성 남성 따로 보는 더미변수 만든 것 추가해줌*/
data B.FINAL1;
SET B.FINAL1;
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
RUN;

data B.FINAL1;
SET B.FINAL1;
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

proc surveyMEANS data=B.FINAL1;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
VAR menwc_1 menwc_2 menwc_3 menwc_4 menwc_5 menwc_6 menwc_7;
run;


/* DENSITY PLOT*/

title 'BMI Distribution in Men';
proc sgplot data=B.FINAL_GRAPH1;
  density menbmi_4/ legendlabel='KNHANESⅣ' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent ;
  /*density menbmi_5/ legendlabel='KNHANESⅤ' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density menbmi_6/ legendlabel='KNHANESⅥ' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;*/
  density menbmi_7/ legendlabel='KNHANESⅦ' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1;
  xaxis label="BMI (kg/m2)";
  yaxis label="Percent" labelpos=top;
  run;
  title 'BMI Distribution in Women';
proc sgplot data=B.FINAL_GRAPH1;
  density WOMENBMI_4/ legendlabel='KNHANESⅣ' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent;
  /*density WOMENBMI_5/ legendlabel='KNHANESⅤ' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density WOMENBMI_6/ legendlabel='KNHANESⅥ' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;*/
  density WOMENBMI_7/ legendlabel='KNHANESⅦ' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1;
  xaxis label="BMI (kg/m2)";
  yaxis label="Percent" labelpos=top;
  run;

  title 'WC Distribution in Men';
proc sgplot data=B.FINAL_GRAPH1;
  density menWC_4/ legendlabel='KNHANESⅣ' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent;
  /*density menWC_5/ legendlabel='KNHANESⅤ' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density menWC_6/ legendlabel='KNHANESⅥ' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;*/
  density menWC_7/ legendlabel='KNHANESⅦ' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1;
  xaxis label="WC (cm)";
  yaxis label="Percent" labelpos=top;
  run;
   title 'WC Distribution in Women';
proc sgplot data=B.FINAL_GRAPH1;
  density womenWC_4/ legendlabel='KNHANESⅣ' lineattrs=(PATTERN=SOLID COLOR=lightGRAY) scale=percent;
  /*density womenWC_5/ legendlabel='KNHANESⅤ' lineattrs=(PATTERN=SOLID COLOR=GRAY) scale=percent;
  density womenWC_6/ legendlabel='KNHANESⅥ' lineattrs=(PATTERN=SOLID COLOR=black) scale=percent;*/
  density womenWC_7/ legendlabel='KNHANESⅦ' lineattrs=(PATTERN=SOLID COLOR=red) scale=percent;
  keylegend / location=inside position=topright across=1;
  xaxis label="WC (cm)";
  yaxis label="Percent" labelpos=top;
  run;



/*graph2: 성별별 차수별 비만, 복부비만 분포 꺾은선 추이그래프(linear graph following research years)*/
proc surveyfreq data=B.FINAL1 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*term*term_obe/row chisq;
run;
proc surveyfreq data=B.FINAL1 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*term*term_ABobe/row chisq;
run;

data B.FINAL_GRAPH2_MEN;
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

data B.FINAL_GRAPH2_WOMEN;
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




/*table1: 성별별 차수별 인구사회학적 요인에 따른 비만과 복부비만 distribution(%)
cage, incm, edu, region_2, occp_2*/
proc surveyreg data=B.FINAL1 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
class cage;
domain SEX*YEAR*CAGE;
model obe=cage /noint vadjust=NONE;
estimate '비만율'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;

proc surveyfreq data=B.FINAL1 nomcar;
STRATA kstrata;
CLUSTER psu;
weight wt_pool_2;
tables SEX*TERM*OCCP_2*TERM_ABOBE/row chisq;
run;


/*graph3: 성별별 차수별 OR 추이그래프(ref as the very first year)*/
proc surveylogistic data=B.FINAL1 nomcar;
strata kstrata;
cluster psu;
weight wt_pool_2;
class cage(ref="2") incm(ref="1") edu(ref="1") region_2(ref="1") occp_2(ref="1") TERM(REF="1");
model TERM_ABOBE(EVENT='1')=TERM CAGE INCM EDU REGION_2 OCCP_2/VADJUST=NONE;
domain SEX;
estimate 'OBESITY'
cage 8262905 8627773 8206397 5147501 3635784 2631178/divisor=36511538;
run;

DATA B.FINAL_GRAPH3_MEN;
INPUT TERM OBE_OR OBE_BOTTOM OBE_UPPER ABOBE_OR ABOBE_BOTTOM ABOBE_UPPER;
CARDS;
1	1	1	1	1	1	1
2	1.351	1.156	1.579	1.153	0.976	1.362
3	1.586	1.355	1.857	1.26	1.055	1.505
4	1.655	1.455	1.882	1.331	1.151	1.539
5	1.654	1.453	1.883	1.264	1.091	1.465
6	1.731	1.521	1.97	1.394	1.209	1.607
7	2.059	1.808	2.345	1.811	1.572	2.085

;
RUN;
DATA B.FINAL_GRAPH3_WOMEN;
INPUT TERM OBE_OR OBE_BOTTOM OBE_UPPER ABOBE_OR ABOBE_BOTTOM ABOBE_UPPER;
CARDS;
1	1	1	1	1	1	1
2	1.129	0.941	1.355	1.056	0.852	1.31
3	1.042	0.859	1.264	1.072	0.871	1.32
4	0.975	0.836	1.138	1.113	0.942	1.317
5	1.087	0.93	1.27	1.112	0.935	1.322
6	1.036	0.885	1.213	0.964	0.808	1.151
7	1.101	0.938	1.293	1.093	0.92	1.299
;
RUN;


DATA B.FINAL_GRAPH3RE_MEN;
INPUT Obesity $ TERM OR UPPER LOWER;
CARDS;
Overall 1	1	1	1
Overall 2	1.351	1.156	1.579
Overall 3	1.586	1.355	1.857
Overall 4	1.655	1.455	1.882
Overall 5	1.654	1.453	1.883
Overall 6	1.731	1.521	1.97
Overall 7	2.059	1.808	2.345
Central 1	1	1	1	
Central 2	1.153	0.976	1.362
Central 3	1.26	1.055	1.505
Central 4	1.331	1.151	1.539
Central 5	1.264	1.091	1.465
Central 6	1.394	1.209	1.607
Central 7	1.811	1.572	2.085
;
RUN;
DATA B.FINAL_GRAPH3RE_WOMEN;
INPUT Obesity $ TERM OR UPPER LOWER;
CARDS;
Overall	1	1	1	1
Overall	2	1.129	0.941	1.355
Overall	3	1.042	0.859	1.264
Overall	4	0.975	0.836	1.138
Overall	5	1.087	0.93	1.27
Overall	6	1.036	0.885	1.213
Overall	7	1.101	0.938	1.293
Central 1	1	1	1
Central 2	1.056	0.852	1.31
Central 3	1.072	0.871	1.32
Central 4	1.113	0.942	1.317
Central 5	1.112	0.935	1.322
Central 6	0.964	0.808	1.151
Central 7	1.093	0.92	1.299
;
RUN;

title 'Adjusted Odds Ratio Trends of Abdominal Obesity and Overall Obesity in Men';
PROC SGPANEL DATA=B.FINAL_GRAPH3re_MEN;
PANELBY Obesity / novarname
layout=panel;
  SCATTER x=term y=OR/ YERRORUPPER=UPPER YERRORLOWER=lower group=Obesity
  groupdisplay=cluster clusterwidth=0.1 markerattrs=(size=7 symbol=circle);
  SERIES X=TERM Y=OR/group=Obesity groupdisplay=cluster clusterwidth=0.1;
rowaxis label="OR" LABELPOS=TOP min=0.5 max=2.5 ;
colaxis label="KNHANES (Ⅰ~Ⅶ)" labelpos=center;
run;
title 'Adjusted Odds Ratio Trends of Abdominal Obesity and Overall Obesity in Women';
PROC SGPANEL DATA=B.FINAL_GRAPH3re_WOMEN;
PANELBY Obesity / novarname
layout=panel;
  SCATTER x=term y=OR/ YERRORUPPER=UPPER YERRORLOWER=lower group=Obesity
  groupdisplay=cluster clusterwidth=0.1 markerattrs=(size=7 symbol=circle);
  SERIES X=TERM Y=OR/group=Obesity groupdisplay=cluster clusterwidth=0.1;
rowaxis label="OR" LABELPOS=TOP min=0.5 max=1.75;
colaxis label="KNHANES (Ⅰ~Ⅶ)" labelpos=center;
run;


/*table2: 성별별 차수별 인구학적 요인에 따른 OR (ref 기준 예전분석 참고)*/  
proc surveylogistic data=B.FINAL1 nomcar;
strata kstrata;
cluster psu;
weight wt_pool_2;
class cage(ref="2") incm(ref="1") edu(ref="1") region_2(ref="1") occp_2(ref="1") ;
model TERM_OBE(EVENT='1')=CAGE INCM EDU REGION_2 OCCP_2/VADJUST=NONE;
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




