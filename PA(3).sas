libname a "C:\Users\HajinJang\OneDrive\OneDrive - 고려대학교\연구실\2021\질본_사망연계\시범\사망연계";

data data07; set a.data07_all; drop LS_type1 LS_type2 LS_type3 LS_type4; run; /*4594*/
data data08; set a.data08_all; drop LS_type1 LS_type2 LS_type3 LS_type4; run; /*9744*/
data data09; set a.data09_all;drop LS_type1 LS_type2 LS_type3 LS_type4; run; /*10533*/
data data10; set a.data10_all;  drop LS_type1 LS_type2 LS_type3 LS_type4; run; /*8958*/
data data11; set a.data11_all;drop LS_type1 LS_type2 LS_type3 LS_type4; run; /*8518*/
data data12; set a.data12_all; drop LS_type1 LS_type2 LS_type3 LS_type4;run; /*8058*/
data data13; set a.data13_all; drop LS_type1 LS_type2 LS_type3 LS_type4;run; /*8018*/

proc sort data=data07; by newkey; run;
proc sort data=data08; by newkey; run;
proc sort data=data09; by newkey; run;
proc sort data=data10; by newkey; run;
proc sort data=data11; by newkey; run;
proc sort data=data12; by newkey; run;
proc sort data=data13; by newkey; run;


*4~6기 통합자료 생성;
data combine;
set data07 data08 data09 data10 data11 data12 data13;
run;
proc contents data=combine;
run;
/*n=58423*/

*데이터 합 확인하기;
proc freq data=combine;
tables YEAR;
run;

*사망자료;

/* 데이터 내에 어떤 변수들이 있는지 확인 */
proc contents data=a.linkage_death; run;  /* mortality data */
proc freq data=a.linkage_death;
tables cause11 cause22;
run;

*사망자료와 합치기;
proc sort data=a.linkage_death; by newkey; run;
proc sort data=combine; by newkey; run;


/*중복변수 없애기*/
data combinedeath;
merge combine(in=n) a.linkage_death(in=m);
by newkey;
if first.newkey then first=1; else first=0; /* to label duplicates, if any */
if n=1 then nhanes=1; else nhanes=0;  /* to label data points present in NHANES dataset */
if m=1 then mort=1; else mort=0; /* to label data points present in mortality dataset */
run;
/*linkage_death 때문에 73353*/
proc freq data=combinedeath;
tables first;
run;
/* cohort=1 if 사망자료 연계참여자 */
/* death=1 if 사망자 */
proc freq data=combinedeath;
tables year nhanes mort year*cohort year*death;
run;
proc freq data=combinedeath;
tables year;
run;


/**************************************/
/*** 1. Restrict to 사망자료 연계참여자 ***/
/**************************************/

data cohort1;
set combinedeath;
where year in (2007:2013);
if cohort=1;
run;
/* n=53420 (5003 excluded) */
/* check your data */
proc freq data=b.cohort1;
tables cohort death year*death;
run;
proc freq data=cohort1;
tables death_year;
run;

/**********************************/
/*** 2. Exclude those at Age<19      ***/
/**********************************/

data cohort2;
set cohort1;
if age<19 then delete;
run;
/*n=40405(13015 excluded)*/
/* check your data, check age if there's any observations with age<20 */
proc means data=b.cohort2;
var age;
run;
/**************************************************/
/*** 3. Exclude those at Age>=95     ***/
/*************************************************/

data cohort3;
set cohort2;
if age>=95 then delete; /* 2007-2012 까지만 95이상 제외, 2013-2015년도는 80세이상은 80으로 코딩되어서 제외불가 */
run;

data cohort3_2;
set cohort3;
if year in ("2007", "2008", "2009", "2010", "2011", "2012") and age>80 then age=80; /* 연령 80세이상인 경우 80 으로 통일시켜 코딩 */
run;
/* n=40399 (6 excluded) */


proc sgplot data=b.cohort2;
where age in (19:80);
histogram age;
density age;
density age /type=kernel;
keylegend / location =inside position=topright;
run;

proc means data=cohort3_2;
var age;
run;

/******************************************/
/*** 4. Exclude if missing outcome (death)  ***/
/*****************************************/
data cohort4;
set cohort3_2;
if death in(0,1);
run;
/*n=40399 (0 excluded) */
proc freq data=b.cohort4;
tables  death*year;
run;

/********************************/
/*** 5. Exclude if BMI<15 or >60  ***/
/********************************/
data cohort5;
set cohort4;
if HE_BMI<13 or HE_BMI>60 then delete;
run;
proc means data=b.cohort5;
var HE_BMI;
run;

/*n=40221(178 excluded)/;

/*************************************/
/*** 6. Exclude if missing age and sex  ***/
/************************************/
data cohort6;
set cohort5;
if age=. or sex=.  then delete;
run;
proc freq data=b.cohort6;
tables  age*year sex*year;
run; 
/*n=40221(0 excluded)*/

/*************************************/
/*** 7. Exclude if having cancer + heart disease & stroke***/
/************************************/
DATA COHORT7;
SET COHORT6;
/*cancer*/
if year in (2007:2009) then do;
if dc1_dg=1 or dc2_dg=1 or dc3_dg=1 or dc4_dg=1 or dc5_dg=1 or dc6_dg=1 or dc11_dg=1 or dc12_dg=1
or dc1_pr=1 or dc2_pr=1 or dc3_pr=1 or dc4_pr=1 or dc5_pr=1 or dc6_pr=1 or dc11_pr=1 or dc12_pr=1 then delete;
end;
if year = 2010 then do;
if dc1_dg=1 or dc2_dg=1 or dc3_dg=1 or dc4_dg=1 or dc5_dg=1 or dc6_dg=1 or dc7_dg=1 or dc11_dg=1 or dc12_dg=1 or dc13_dg=1
or dc1_pr=1 or dc2_pr=1 or dc3_pr=1 or dc4_pr=1 or dc5_pr=1 or dc6_pr=1 or dc11_pr=1 or dc12_pr=1 or dc13_pr=1 then delete;
end;
if year in (2011:2013) then do;
if dc1_dg=1 or dc2_dg=1 or dc3_dg=1 or dc4_dg=1 or dc5_dg=1 or dc6_dg=1 or dc7_dg=1 or dc11_dg=1 
or dc1_pr=1 or dc2_pr=1 or dc3_pr=1 or dc4_pr=1 or dc5_pr=1 or dc6_pr=1 or dc7_pr=1 or dc11_pr=1  then delete;
end;
run;
*n=38909 (exclude : 1312);

data cohort7_2;
set cohort7;
/*심장질환, 뇌졸중*/
if di3_dg=1 or di4_dg=1 or di5_dg=1 or di6_dg=1 
or di3_pr=1 or di4_pr=1 or di5_pr=1 or di6_pr=1  then delete;
RUN;
*n=37265 (exclude : 1644);
/*신체활동 측정 가능한 값 missing*/
data cohort8;
set cohort7_2;
if (BE3_11>8 or BE3_11=.) &(BE3_21>8 or BE3_21=.) & (BE3_31>8 or BE3_31=.) then delete; *모든 값들이 비해당, 모름 무응답, 결측치;
if (BE3_11 in (2:7) and (BE3_11=99 or BE3_11=.))& (BE3_21 in (2:7) and (BE3_21=99 or BE3_21=.))&(BE3_31 in (2:7) and (BE3_31=99 or BE3_31=.)) then delete; *일수는 있는데 전부 다 시간 값이 전부 없는 경우;
run;
*n=36119 (exclude : 1146); 

/*신체활동 불가능한 사람*/
data cohort9;
set cohort8;
if lq_1eql=3 then delete; *운동능력이 부재한 사람 - 나는 종일 누워 있어야 함;
*if lq_2eql=3 then delete; *자기 관리: 나는 혼자 목욕을 하거나 옷을 입을 수 없음;
*if lq_3eql=3 then delete; *일상생활에 지장 : 나는 일상활동을 할 수 없음;
run;
*n=35917(exclude=202);
/*1년 내 사망한 사람*/
data cohort10;
set cohort9;
if .<person_y=<1 then delete;
run;
*n=35820(exclude= 97);
proc freq data=b.cohort10;
tables sex;
run;

proc means data=b.cohort10;
var age;
run;

proc freq data=b.cohort11;
tables marricat smkcat;
run;


/************************************************/
/************************************************/
/***************Covariates************************/
/************************************************/
/************************************************/
data cohort11;
set cohort10;

*근력운동 실천율;
if be5_1 in (1:6) then do;
if be5_1 in (1,2) then pa_muscle=0;
if be5_1 in (3:6) then pa_muscle=1;
end;
else pa_muscle=.;

*당뇨병 유병 여부;
if he_glu^=. & he_fst>=8 & de1_dg in (0,1,8) & de1_31 in (0,1,8) & de1_32 in (0,1,8) then do;
if he_glu=>126 or de1_31=1 or de1_32=1 or de1_dg=1 then dm_pr=1;
else dm_pr=2;
end;
else dm_pr=.;

*고혈압 유병 여부;
if he_sbp^=. & he_dbp^=. & di1_2 in (1,2,3,4,5,8) and year in (2007:2009) then do;
if he_sbp_tr=>140 or he_dbp_tr=>90 or di1_2 in (1:4) then hp_pr=1;
else hp_pr=2;
end;

else if  he_sbp^=. & he_dbp^=. & di1_2 in (1,2,3,4,5,8) and year in (2010:2015) then do;
if he_sbp=>140 or he_dbp=>90 or di1_2 in (1:4) then hp_pr=1;
else hp_pr=2;
end;
else hp_pr=.;

*연령구간 나누기;
if age ne . then do;
if age in (19:49) then agecat=1;
else if age in (50:59) then agecat=2;
else if age in (60:69) then agecat=3;
else if age>=70 then agecat=4;
end;

*65세 미만/ 이상;

if age ne . then do;
if age in (20:64) then seniorcat=0;
else if age>=65 then seniorcat=1;
end;
else seniorcat=.;

*교육 수준 나누기;
if edu in (1:4) then do;
if edu in (1:2) then educat=1;*중졸 이하;
else if edu=3 then educat=2;*고졸;
else if edu=4 then educat=3; *대졸 이상;
end;
else educat=.;

*경제활동 상태(ec1_1=1 :취업자, 2는 미취업자);
if ec1_1>2 then ec1_1=.;

*직업 분류 - 육체노동자, 비육체노동자;
if occp in (1:3) then p_work=0;*비육체노동자;
else if occp in (4:6) then p_work=1;*육체 노동자;
else p_work=.;

*새로 변수 생성;
if ec1_1=1 and occp in (1:3) then occp_new=1;*비육체 노동자;
else if ec1_1=1 and occp in (4:6) then occp_new=2;*육체 노동자;
else if ec1_1=2 then occp_new=3;*미취업자;

*소득 사분위수 (1-하, 2-중하,3-중상, 4-상);
if ho_incm>4 then ho_incm=.;

*결혼 상태;
if year in (2007:2009) and marri_1 in (1:2)  then do;
if marri_1=1 and marri_2=1 then marricat=1;*기혼;
else if marri_1=2 then marricat=2;*미혼;
else if  (marri_1=1 & marri_2=3) then marricat=3; *사별;
else if (marri_1=1 & marri_2=4) or (marri_1=1 & marri_2=2) then marricat=4;*별거,이혼;
end;
else if year in (2010:2013) and marri_1 in (1:2)  then do;
if marri_1=1 and marri_2=1 then marricat=1;*기혼;
else if marri_1=2 then marricat=2;*미혼;
else if  (marri_1=1 & marri_2=3) then marricat=3; *사별;
else if (marri_1=1 & marri_2=4) or (marri_1=1 & marri_2=2) then marricat=4;*별거,이혼;
end;
else marricat=.;

if marricat in (1:4) then do;
if marricat=1 then marricat_new=1;*기혼;
else if marricat=2 then marricat_new=2;*미혼;
else if marricat in (3,4) then marricat_new=3;*사별, 별거, 이혼;
end;
else marricat_new=.;


*흡연 상태;
if year in (2007:2009) & BS1_1 in (1:3) & BS3_1 in (1,2,3,8) then do;
if (BS1_1=1 & BS3_1 in (1:2)) or BS1_1=3 then smkcat=1;*비흡연;
else if BS1_1=2 & BS3_1=2 then smkcat=2;*과거흡연;
else if BS1_1=2 & BS3_1=1 then smkcat=3;*현재흡연;
end;
else
if year in (2010:2013) & BS1_1 in (1:3) & BS3_1 in (1,2,3,8) then do;
if (BS1_1=1 & BS3_1 in (1:3)) or BS1_1=3 then smkcat=1;
else if BS1_1=2 & BS3_1=3 then smkcat=2;
else if BS1_1=2 & BS3_1 in (1:2) then smkcat=3;
end;
else smkcat=.;
*BMI;
if HE_BMI<18.5 then bmicat=1;
else if 18.5=<HE_BMI<23 then bmicat=2;
else if 23=<HE_BMI<25 then bmicat=3;
else if 25=<HE_BMI then bmicat=4;
ELSE bmicat=. ;
* 음주 구분-월간 평균 음주 횟수;
if bd1 in (1:2)  then do;
if bd1=1 or (bd1=2 & bd1_11=1) then drinkcat=1;*평생 비음주 또는 과거음주;
else if bd1=2 & bd1_11 in (2:4) then drinkcat=2;*최근 1 년간 1주일에 1회 이하 음주;
else if bd1=2 & bd1_11=5  then drinkcat=3;*최근 1 년간 주 2-3회 음주;
else if bd1=2 & bd1_11=6  then drinkcat=4;*최근 1년간 주 4회 이상 음주;
end;
else drinkcat=.;
* 주관적 건강;
if D_1_1 in (1:5) then do;
if D_1_1 in (1:2) then dcat=1;*좋음;
else if D_1_1=3 then dcat=2;*보통;
else if D_1_1 in (4:5) then dcat=3;*나쁨;
end;
else dcat=.;
*지역;
if region in (1:16) and town_t in (1:2) then do;
if region in (1:7) then regioncat=1;*서울+광역시;
else if region in (8:16) and town_t=1 then regioncat=2;*8도+동;
else if region in (8:16) and town_t=2 then regioncat=3;*8도+읍면;
end;
run;

data  cohort11_1;
set  cohort11;
if "C00"<=cause11<="D48" or "C00"<=cause22<="D48"  then cancerdeath=1;
else cancerdeath=0;  /*379 deaths */

if "I00"<=cause11<="I99" or "I00"<=cause22<="I99" then cvddeath=1;
else cvddeath=0;  /* 238 deaths */
if "J00"<=cause11<="J99" or "J00"<=cause22<="J99" then respdeath=1; else respdeath=0;  
if "S00"<=cause11<="S99" or "T00"<=cause11<="T98" then accidentdeath=1;
else if "S00"<=cause22<="S99" or "T00"<=cause22<="T98" then accidentdeath=1; else accidentdeath=0;

run;

data cohort11_2;
set cohort11_1;
*MET 구하기;

/* 격렬한 신체활동 빈도 확인하기************/
if be3_11=1 then pa=0;

if be3_12 in (0:24) and be3_13 in (0:59) and be3_11 in (2:8) then do;
pa_day=BE3_11-1; /* 격렬한 신체활동 나타내는 변수 PA*/
pa_time=BE3_12+(BE3_13/60); 
pa_time_wk= pa_time*pa_day;*일주일동안!;
end;
else pa_time_wk=.;
/*************************************/
/* 중증도  신체활동 빈도 확인하기************/
if be3_21=1 then pa2=0;

if be3_22 in (0:24) and be3_23 in (0:59) and be3_21 in (2:8) then do;
pa_day2=BE3_21-1;
/*PA2=중증도 신체활동*/
pa_time2=BE3_22+(BE3_23/60);
pa_time_wk2= (pa_day2*pa_time2);
end;

else pa_time_wk2=.;
 
/*걷기 */
if be3_31=1 then walk=0;
if be3_32 in (0:24) and be3_33 in (0:59) and be3_31 in (2:8) then do;
walk_day=BE3_31-1;

/*Wday=걷기*/
walk_time=BE3_32+(BE3_33/60);
walk_time_wk= walk_day*walk_time;
end;
else walk_time_wk=.;
run;
proc freq data=b.cohort11_2;
tables pa pa2 walk;
run;
proc univariate data=b.cohort11_2;
var pa_time_wk2;
run;

data cohort12;
set cohort11_2;
if pa ne . then v_pa=pa;
if pa_time_wk ne . then v_pa=pa_time_wk;
if pa2 ne . then m_pa=pa2;
if pa_time_wk2 ne . then m_pa=pa_time_wk2;
if walk ne . then w_pa=walk;
if walk_time_wk ne . then w_pa=walk_time_wk;
run;



*너무 많이운동한다고 답한 사람. 믿을 수 없는 사람의 응답은 어떤 값 부터일까?;
/*sum function은 missing value까지 다 포함해서 계산해주기때문에 missing을 그대로 남겨주는 + 이용해서 계산*/

data cohort13;
set cohort12;

/*2007-2013 total met*/
if v_pa ne . and m_pa  ne . and w_pa ne . then totmet=(w_pa*3.3)+(m_pa*4)+(v_pa*8);
else totMET=.;
if v_pa ne . and m_pa  ne . then modvigmet=(m_pa*4)+(v_pa*8);
else modvigmet=.;
*if  pa_time_wk ne . and pa_time_wk2 ne . then modvigMET=(pa_time_wk2*4)+(pa_time_wk*8);
*else modvigMET=.;
run;
proc sgplot data=b.cohort13;
histogram totMET;
density totMET;
proc sgplot data=b.cohort13;
histogram modvigmet;
density modvigmet;
run;
proc univariate data=b.cohort13;
var totMET modvigmet;
run;


data cohort14;
set cohort13;
if  totmet=0 then totcat=0;
else if 0< totmet<10 then totcat=1;
else if 10<= totmet<20 then totcat=2;
else if  totmet>=20 then totcat=3;

if  modvigmet=0 then modvigcat=0;
else if 0< modvigmet<10 then modvigcat=1;
else if 10<= modvigmet<20 then modvigcat=2;
else if  modvigmet>=20 then modvigcat=3;
run;
/*신체활동 가이드라인 실천 여부*/
data cohort15;
set cohort14;
if totcat in (0:3) and pa_muscle in (0:1) then do;
if totcat in (0:1) and pa_muscle=0 then tot_m=0;*근력x유산소x;
if totcat in (0:1) and pa_muscle=1 then tot_m=1;*근력o유산소x;
if totcat in (2:3) and pa_muscle=0 then tot_m=2;*근력x유산소o;
if totcat in (2:3) and pa_muscle=1 then tot_m=3;*근력o 유산소o;
end;
if modvigcat in (0:3) and pa_muscle in (0:1) then do;
if modvigcat in (0:1) and pa_muscle=0 then modvig_m=0;*근력x유산소x;
if modvigcat in (0:1) and pa_muscle=1 then modvig_m=1;*근력o유산소x;
if modvigcat in (2:3) and pa_muscle=0 then modvig_m=2;*근력x유산소o;
if modvigcat in (2:3) and pa_muscle=1 then modvig_m=3;*근력o 유산소o;
end;
run;


data cohort16;
set cohort15;
if be5_1 in (1:6) then do;
if be5_1=1 then muscle_freq=0;
if be5_1=2 then muscle_freq=1; *1회;
if be5_1=3 then muscle_freq=2;*2회;
if be5_1 in (4:6) then muscle_freq=3; *2회 초과;
end;
else muscle_freq=.; 

if be5_1 in (1:6) then do;
if be5_1=1 then muscle_freq2=0;
if be5_1 in (2:3) then muscle_freq2=1; *1-2회;
if be5_1 in (4:6) then muscle_freq2=2; *2회 초과;
end;
else muscle_freq2=.; 
run;

/*중강도에서만 guideline , 고강도에서만 guideline*/
data cohort17;
set cohort16;
if m_pa ne . then do;
if m_pa=0 then only_m=0; *0met;
if 0<m_pa<10 then only_m=1;*guideline 못 맞춤;
if m_pa in (10:19) then only_m=2; *10~19 met;
if m_pa>=20 then only_m=3; *20이상;
end;
else only_m=.;
if v_pa ne . then do;
if v_pa=0 then only_v=0; *0met;
if 0<v_pa<10 then only_v=1;*guideline 못 맞춤;
if v_pa in (10:19) then only_v=2; *10~19 met;
if v_pa>=20 then only_v=3; *20이상;
end;
else only_v=.;

*guideline ox;
if m_pa ne . then do;
if 0<=m_pa<10 then only_m2=0;*guideline 못 맞춤;
if m_pa>=10  then only_m2=1; *10+met;
end;
else only_m2=.;
if v_pa ne . then do;
if 0<=v_pa<10 then only_v2=0;*guideline 못 맞춤;
if v_pa>=10  then only_v2=1; *10+met;
end;
else only_v2=.;
run;

proc freq data=b.cohort_final;
where only_v2=1;
table totmet; run;

/*table2 만들기*/

data cohort_v2;
set cohort17;
py1=person_y-1; /* because we excluded all death <1 years, all person-time should start after year 1, otherwise it will make immortal time bias */
pm1=person_m-12;
pd1=person_d-30;

py1r = round(py1, .02);   /* 소수점 2째자리까지 표시하겠다. 그 밑에서 반올림! */
pm1r = round(pm1, .02);   

py_m=(age+1+py1r)*12;

/** age as time metric *
entry_age1=age+1;
exit_age1=entry_age1+py1;*/
entry_age1=(age+1)*12;
exit_age1=entry_age1+pm1;
/***************1년 내 사망자 제외

/*2년으로 한 번 해보기*/
py2=person_y-2;
pm2=person_m-24;

py2r=round(py2,.02);
entry_age2=age+2;
exit_age2=entry_age2+py2;
run;
proc surveymeans data=b.cohort_v2;
var py1r pm1r py_m age entry_age1 exit_age1; run;
proc freq data=b.cohort_v2;
table py_m; run;
proc contents data=a.linkage_death; run;

proc means data=b.cohort_v2 sum;
var py1r;
run;
/*metabolic syndrome check*/
/******* BMI and metabolic health *****/
/* he_hp_tr 고혈압 유병여부 1=정상, 2=전단계, 3=고혈압 */
/* he_dm 당뇨병, 1=정상, 2=공복혈당장애, 3=당뇨병 */
/* HE_hCHOL 고콜레스테롤혈증 0/1 공복시 총콜레스테롤≥240㎎/㎗ 또는 콜레스테롤약 복용*/
/* HE_hTG 고중성지방혈증 12시간 이상 공복시 중성지방 200㎎/㎗ 이상 */
/* HE_LHDL_st 저HDL-콜레스테롤혈증 8시간이상 공복자 중 HDL콜레스테롤(전환식 적용)이 40㎎/dL 미만  */

/* metabolic syndrome (International Diabetes Federation cutpoints?) */

/*사망자 수 확인*/
data cohort_v2_2;
set cohort_v2;

ms_wc=0;
if sex=1 and he_wc>=90 then ms_wc=1;
else if sex=2 and he_wc>=85 then ms_wc=1;
else if he_wc=. then ms_wc=.;

ms_TG=0;
if he_TG>=150 then ms_TG=1;
else if dI2_2<5 then ms_TG=1;  /* 고지혈증제 복용 */
else if he_TG=. then ms_TG=.;

ms_HDL=0;
if sex=1 and he_HDL_st2<40 then ms_HDL=1;
else if sex=2 and he_HDL_st2<50 then ms_HDL=1;
else if dI2_2<5 then ms_HDL=1;
else if he_HDL_st2=. then ms_HDL=.;

/* 당뇨병 */
if DE1_dg=1 or DE1_pr=1 or DE1_lt=1 
then diabetes=1; else diabetes=0;

ms_glu=0;
if he_glu>=100 then ms_glu=1;
else if DE1_31=1 then ms_glu=1; /* insulin 주사 */
else if DE1_32=1 then ms_glu=1; /* 당뇨병약 */
else if diabetes=1 then ms_glu=1; /* 당뇨병 진단 */
else if he_glu=. then ms_glu=.;

ms_HTN=0;
if he_sbp>=130 or he_dbp>=85 or DI1_2<5 then ms_HTN=1; /* dI1_2 혈압조절제 복용 */
else if he_sbp=. or he_dbp=. then ms_HTN=.;

if ms_wc ne . and ms_TG ne . and ms_HDL ne . and ms_glu ne . and ms_HTN ne . 
then ms_score = sum(ms_wc, ms_TG, ms_HDL, ms_glu,  ms_HTN);
else ms_score=.;

if .<ms_score<3 then ms_final=0;
else if ms_score>=3 then ms_final=1; /* 3 or more --> metabolic syndrome */
else ms_final=.;

if ms_score=5 then ms_all=1;
else if ms_score in(1,2,3,4) then ms_all=0;
else ms_all=.;

/*연령 표준화율 연령변수*/
if age in (19:29) then cage=1;
if age in (30:39) then cage=2;
if age in (40:49) then cage=3;
if age in (50:59) then cage=4;
if age in (60:69) then cage=5;
if age>=70 then cage=6;

if year in (2007:2013) then do;
if year in (2007:2009) then wt_pool_1=wt_ex;
if year in (2010:2013) then wt_pool_1=wt_itvex;
end;

run;

/*****************************************************/
/*********************최종 exclusion*******************/
/*****************************************************/

data cohort_v3;
set cohort_v2_2;
if modvig_m= . or modvigcat=. or muscle_freq=. then delete;
run;
/*35723 (97 excluded)*/

/*death 분포 확인*/
proc freq data=b.cohort_v3;
tables death*modvig_m cancerdeath*modvig_m cvddeath*modvig_m;
run;
proc freq data=b.cohort_v3;
tables modvigcat muscle_freq modvig_m;
run;
proc means data=b.cohort_v3 sum;
class modvig_m;
var py1r;
run;
/*각 변수 별 missing data 수 확인*/
proc freq data=b.cohort_v3;
tables sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat;
run;
proc means data=b.cohort_v2_2 n nmiss;
var modvig_m  modvigcat muscle_freq2 sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat;
run;
/*결측치 처리-모두 1.5%미만*/
data cohort_final;
set cohort_v3;
if pa_walk=. then pa_walk=0;
if educat=. then educat=2;
if occp_new=. then occp_new=3;
if ho_incm=. then ho_incm=4;
if marricat_new=. then marricat_new=1;
if drinkcat=. then drinkcat=1;
if smkcat=. then smkcat=1;
if dcat=. then dcat=2;
run;
proc freq data=b.cohort_final;
tables sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat bmicat;
run;

proc freq data=b.cohort_final;
tables walk_time_wk w_pa; run;
proc freq data=b.cohort_final;
where modvigmet<10;
tables w_pa; run;

proc freq data=b.cohort_final;
tables pa_walk*modvig_m;
run;


/************************************************/
/************************************************/
/************** Model 시작 ************************/
/************************************************/
/************************************************/
/*******all cause mortality*****/
proc freq data=B.COHORT_FINAL; 
table modvig_m*death / NOPERCENT NOCOL;
run;
proc means data=b.cohort_final  n mean sum;
class modvig_m;
var py1r;
run;

proc freq data=b.cohort_final ; 
table modvig_m*cancerdeath / NOPERCENT NOCOL;
run;
/***********1020 poster dose response*********/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class be5_1  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk modvigcat/param=ref ref=first;
model exit_age1*death(0) =  be5_1  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk modvigcat/rl entry=entry_age1;
strata year ;
run;

proc surveylogistic data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class be5_1  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk modvigcat/param=ref ref=first;
model death(event='1') =  be5_1  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk modvigcat;
strata year ;
run;

data cohort1; set b.cohort_final;
if  modvigmet=0 then postercat=0;
else if 0< modvigmet<5 then postercat=1;
else if 5<=modvigmet<10 then postercat=2;
else if 10<= modvigmet<20 then postercat=3;
else if  modvigmet>=20 then postercat=4;
run;
proc phreg data=cohort1;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class postercat muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*death(0) = postercat muscle_freq2  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk/rl entry=entry_age1;
strata year ;
run;

proc surveylogistic data=cohort1;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class postercat  year  bmicat muscle_freq2 sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model death(event='1') =  postercat muscle_freq2  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk ;
strata year ;
run;

/*********interaction*********/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq2*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq2*modvigcat/rl entry=entry_age1;
strata year ;
run;

proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq2*modvigcat/rl entry=entry_age1;
strata year ;
run;


/*******************1015미팅준비**********************/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat pa_muscle/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat pa_muscle /rl entry=entry_age1;
strata year ;
run;

/*
modvigmet
be5_1*/

proc freq data=b.cohort_final; 
table modvigmet; run;

options nocenter ps=78 ls=80 replace formdlim=’=’
mautosource
sasautos=(’/usr/local/channing/sasautos’,
’/proj/nhsass/nhsas00/nhstools/sasautos’);

%lgtphcurv9(data=b.cohort_final, time=pm1r, model=cox,
exposure=modvigmet, refval=0, case=death, hicut=900, lowcut=0, nk=5,
adj=sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat,
plot=2, testrep=short, modprint=f,
hlabel=%quote(MET (hour/week)), axordh=0 to 900 by 10,
vlabel=Hazard Ratio of all-cause mortality, axordv=.5 to 1.5 by .1,
pictname=example12a.ps,
43
header1=MET and Mortality, graphtit=NONE, footer=NONE);

/***************dose response***********************/
proc freq data=cohort15; 
table modvigcat*death / NOPERCENT NOCOL;
run;
proc means data=cohort15  n mean sum;
class modvigcat;
var pm1r;
run;

proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year pa_muscle bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvigcat pa_muscle sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;

proc freq data=b.cohort_final;
table modvigcat*cvddeath / NOPERCENT NOCOL;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year pa_muscle bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat pa_muscle sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;

proc freq data=b.cohort_final;
table modvigcat*cancerdeath / NOPERCENT NOCOL;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year pa_muscle bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvigcat pa_muscle sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;


/**********muscle 보정 다르게**********/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year muscle_freq bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvigcat muscle_freq sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;

proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year muscle_freq bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat muscle_freq sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;

proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year muscle_freq bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvigcat muscle_freq sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;


/***************dose response(muscle frequency)***********************/
proc freq data=b.cohort_final;
table muscle_freq*death / NOPERCENT NOCOL;
run;
proc means data=cohort15  n mean sum;
class muscle_freq;
var pm1r;
run;

proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq  pa_walk year  modvigcat bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  muscle_freq  modvigcat sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;

proc freq data=b.cohort_final;
table muscle_freq*cvddeath / NOPERCENT NOCOL;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq  pa_walk year  modvigcat bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq  modvigcat sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;

proc freq data=b.cohort_final;
table muscle_freq*cancerdeath / NOPERCENT NOCOL;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq  pa_walk year  modvigcat bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cancerdeath(0) =  muscle_freq  modvigcat sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;



/*****************************************************/
/***************All cause mortality*************************/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  /rl entry=entry_age1;
strata year ;
run;
*model2: lifestyle;
/*********interaction*********/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk muscle_freq modvigcat /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq modvigcat muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk /rl entry=entry_age1;
strata year ;
run;
/**reported health*/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;
/******model 4 add ms_final****/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final /rl entry=entry_age1;
strata year ;
run;



/*************CVD mortality*******************************/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  /rl entry=entry_age1;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk /rl entry=entry_age1;
strata year ;
run;
/**reported health*/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;
/******model 4 add ms_final****/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final /rl entry=entry_age1;
strata year ;
run;

/********Cancer Mortality*****/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  /rl entry=entry_age1;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk /rl entry=entry_age1;
strata year ;
run;
/**reported health*/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;
/******model 4 add ms_final****/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final /rl entry=entry_age1;
strata year ;
run;























proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;


proc phreg data=cohort15;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk  muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age1*cancerdeath(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new bmicat drinkcat smkcat pa_walk muscle_freq*modvigcat/rl entry=entry_age1;
strata year ;
run;
*model3: reported health;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;
*model 4: ms_final;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  ms_final/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat ms_final /rl entry=entry_age1;
strata year ;
run;

proc means data=b.cohort_final sum;
where modvig_m=0;
var py1r;
proc means data=b.cohort_final sum;
where modvig_m=1;
var py1r;
proc means data=b.cohort_final sum;
where modvig_m=2;
var py1r;
proc means data=b.cohort_final sum;
where modvig_m=3; 
var py1r;
run;

proc means data=b.cohort_final;
var py1r;
run;


 /*table4- modvigmet */
*modvigcat;
*model1: basic demographic factors;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex educat regioncat occp_new ho_incm marricat_new  pa_walk /rl entry=entry_age1;
strata year ;
run;









*model2: lifestyle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat pa_walk  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk /rl entry=entry_age1;
strata year ;
run;
*model3: reported health;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  pa_walk/rl entry=entry_age1;
strata year ;
run;
*model3+muscle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat pa_muscle/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat pa_muscle /rl entry=entry_age1;
strata year ;
run;
proc freq data=cohort_v2_2;
tables death*modvigcat death*modvigcat cvddeath*modvigcat;
run;

proc means data=b.cohort_final sum;
where modvigcat=0;
var py1r;
proc means data=b.cohort_final sum;
where modvigcat=1;
var py1r;
proc means data=b.cohort_final sum;
where modvigcat=2;
var py1r;
proc means data=b.cohort_final sum;
where modvigcat=3;
var py1r;
run;
proc freq data=b.cohort_final;
tables death*modvigcat
cancerdeath*modvigcat
cvddeath*modvigcat
; run;

 /*table5- muscle */
*muscle_freq2;
*model1: basic demographic factors;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  sex educat regioncat occp_new ho_incm marricat_new    /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex educat regioncat occp_new ho_incm marricat_new   /rl entry=entry_age1;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat   /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat  /rl entry=entry_age1;
strata year ;
run;
*model3: reported health;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;
*model3+aerobic;
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class   year   muscle_freq2 bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat modvigcat /rl entry=entry_age1;
strata year ;
run;
proc freq data=cohort_v2_2;
tables death*muscle_freq2 death*muscle_freq2 cvddeath*muscle_freq2;
run;

proc means data=b.cohort_final sum;
where muscle_freq2=0;
var py1r;
proc means data=b.cohort_final sum;
where muscle_freq2=1;
var py1r;
proc means data=b.cohort_final sum;
where muscle_freq2=2;
var py1r;
run;
proc freq data=b.cohort_final;
tables death*muscle_freq2
cancerdeath*muscle_freq2
cvddeath*muscle_freq2;
run;

proc logistic data=cohort_v2_2;
model death=muscle_freq2;
test muscle_freq2;
run;

/*table6 - interacton이랑 age 나눠서*/
*modvig_m, seniorcat;
*model3: reported health;
proc phreg data=cohort_v2_2;
*where seniorcat=1;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk age*modvig_m /rl entry=entry_age1;
strata year ;
run;

proc freq data=cohort_v2_2;
where seniorcat=1;
tables death*modvig_m death*modvig_m cvddeath*modvig_m;
run;

proc means data=cohort_v2_2 sum;
where seniorcat=1 and modvig_m=0;
var py1r;
proc means data=cohort_v2_2 sum;
where seniorcat=1 and modvig_m=1;
var py1r;
proc means data=cohort_v2_2 sum;
where seniorcat=1 and  modvig_m=2;
var py1r;
proc means data=cohort_v2_2 sum;
where seniorcat=1 and  modvig_m=3;
var py1r;
run;
*p-trend 이렇게 보는 것이 맞는가...;

proc logistic data=cohort_v2_2;
model cvddeath =muscle_freq2;
test muscle_freq2;
run;

/*Sensitivity1-exit_age2*/
/*2년으로 한 번 해보기- 그리고 2년 내로 사망한 사람 다 지움*/
/*py2=person_y-2;
py2r=round(py2,.02);
entry_age2=age+2;
exit_age2=entry_age2+py2;
*/
data b.cohort_final2;
set b.cohort_final;
if .<person_y=<2 then delete;
run;
/*35570*/
/*1-modvig_m (interaction : modvigcat*muscle_freq2)  */
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age2*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat_new  pa_walk   /rl entry=entry_age2;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age2*death(0) =  modvig_m  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk /rl entry=entry_age2;
strata year ;
run;
*model3: reported health;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age2*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age2;
strata year ;
run;

proc means data=b.cohort_final2 sum;
where modvig_m=0;
var py2r;
proc means data=b.cohort_final2 sum;
where modvig_m=1;
var py2r;
proc means data=b.cohort_final2 sum;
where modvig_m=2;
var py2r;
proc means data=b.cohort_final2 sum;
where modvig_m=3;
var py2r;
run;

proc freq data=b.cohort_final2;
tables death*modvig_m cancerdeath*modvig_m cvddeath*modvig_m;
run;



 /*- modvigmet :여기서부터!!! 다시!*/
*modvigcat;
*model1: basic demographic factors;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  sex educat regioncat occp_new ho_incm marricat_new   pa_walk /param=ref ref=first;
model exit_age2*cvddeath(0) =  modvigcat  sex educat regioncat occp_new ho_incm marricat_new  pa_walk /rl entry=entry_age2;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat pa_walk  /param=ref ref=first;
model exit_age2*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat pa_walk /rl entry=entry_age2;
strata year ;
run;
*model3: reported health;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age2*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  pa_walk/rl entry=entry_age2;
strata year ;
run;
*model3+muscle;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat pa_muscle/param=ref ref=first;
model exit_age2*cvddeath(0) =  modvigcat  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat pa_muscle /rl entry=entry_age2;
strata year ;
run;
proc freq data=b.cohort_final2;
tables death*modvigcat cancerdeath*modvigcat cvddeath*modvigcat;
run;

proc means data=b.cohort_final2  sum;
where modvigcat=0;
var py2r;
proc means data=b.cohort_final2  sum;
where modvigcat=1;
var py2r;
proc means data=b.cohort_final2  sum;
where modvigcat=2;
var py2r;
proc means data=b.cohort_final2  sum;
where modvigcat=3;
var py2r;
run;
*p trend 구해보기;
proc logistic data=cohort_v3;
model cvddeath =modvigcat;
test modvigcat;
run;

*3- muscle;
*muscle_freq2;
*model1: basic demographic factors;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  sex educat regioncat occp_new ho_incm marricat_new    /param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex educat regioncat occp_new ho_incm marricat_new   /rl entry=entry_age2;
strata year ;
run;
*model2: lifestyle;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat   /param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat  /rl entry=entry_age2;
strata year ;
run;
*model3: reported health;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat  /rl entry=entry_age2;
strata year ;
run;
*model3+aerobic;
proc phreg data=b.cohort_final2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat_new drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat_new drinkcat smkcat dcat modvigcat /rl entry=entry_age2;
strata year ;
run;
proc freq data=cohort_v3;
where py2r>0;
tables death*muscle_freq2 death*muscle_freq2 cvddeath*muscle_freq2;
run;

proc means data=cohort_v3 sum;
where muscle_freq2=0;
var py2r;
proc means data=cohort_v3 sum;
where muscle_freq2=1;
var py2r;
proc means data=cohort_v3 sum;
where muscle_freq2=2;
var py2r;
run;
proc logistic data=cohort_v3;
model cvddeath=muscle_freq2;
test muscle_freq2;
run;

/*sensitivity1-2: 2년 이전에 사망한 사람 다 지운 거*/
data cohort_s2;
set cohort_v3;
if .<person_y=<2 then delete;
run;
/*2년으로 한 번 해보기
py2=person_y-2;
py2r=round(py2,.02);
entry_age2=age+2;
exit_age2=entry_age2+py2;
modvigcat*muscle_freq2 
*/
/*1-modvig_m*/
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  sex educat regioncat occp_new ho_incm marricat   pa_walk /param=ref ref=first;
model exit_age2*death(0) =  modvig_m  sex educat regioncat occp_new ho_incm marricat  pa_walk   /rl entry=entry_age2;
strata year ;
run;
*model2: lifestyle;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat  pa_walk/param=ref ref=first;
model exit_age2*death(0) =  modvig_m  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat pa_walk    /rl entry=entry_age2;
strata year ;
run;
*model3: reported health;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age2*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat    /rl entry=entry_age2;
strata year ;
run;

proc means data=cohort_s2 sum;
where modvig_m=0;
var py2r;
proc means data=cohort_s2 sum;
where modvig_m=1;
var py2r;
proc means data=cohort_s2 sum;
where modvig_m=2;
var py2r;
proc means data=cohort_s2 sum;
where modvig_m=3;
var py2r;
run;

proc freq data=cohort_s2;
where py2r>0;
tables cvddeath*modvig_m;
run;



 /*- modvigmet */
*modvigcat;
*model1: basic demographic factors;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  sex educat regioncat occp_new ho_incm marricat   pa_walk /param=ref ref=first;
model exit_age2*death(0) =  modvigcat  sex educat regioncat occp_new ho_incm marricat  pa_walk /rl entry=entry_age2;
strata year ;
run;
*model2: lifestyle;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat pa_walk  /param=ref ref=first;
model exit_age2*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat pa_walk /rl entry=entry_age2;
strata year ;
run;
*model3: reported health;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age2*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk/rl entry=entry_age2;
strata year ;
run;
*model3+muscle;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat pa_muscle/param=ref ref=first;
model exit_age2*death(0) =  modvigcat  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat pa_muscle /rl entry=entry_age2;
strata year ;
run;
proc freq data=cohort_s2;
where py2r>0;
tables death*modvigcat death*modvigcat death*modvigcat;
run;

proc means data=cohort_s2 sum;
where modvigcat=0;
var py2r;
proc means data=cohort_s2 sum;
where modvigcat=1;
var py2r;
proc means data=cohort_s2 sum;
where modvigcat=2;
var py2r;
proc means data=cohort_s2 sum;
where modvigcat=3;
var py2r;
run;
*p trend 구해보기;
proc logistic data=cohort_s2;
model death =modvigcat;
test modvigcat;
run;

*3- muscle;
*muscle_freq2;
*model1: basic demographic factors;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  sex educat regioncat occp_new ho_incm marricat    /param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex educat regioncat occp_new ho_incm marricat   /rl entry=entry_age2;
strata year ;
run;
*model2: lifestyle;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat   /param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat  /rl entry=entry_age2;
strata year ;
run;
*model3: reported health;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  /rl entry=entry_age2;
strata year ;
run;
*model3+aerobic;
proc phreg data=cohort_s2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age2*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat /rl entry=entry_age2;
strata year ;
run;
proc freq data=cohort_s2;
where py2r>0;
tables death*muscle_freq2 death*muscle_freq2 death*muscle_freq2;
run;

proc means data=cohort_s2 sum;
where muscle_freq2=0;
var py2r;
proc means data=cohort_s2 sum;
where muscle_freq2=1;
var py2r;
proc means data=cohort_s2 sum;
where muscle_freq2=2;
var py2r;
run;
proc logistic data=cohort_s2;
model death=muscle_freq2;
test muscle_freq2;
run;

/*Stratification : 어디에서 HR이 차이가 나는 것일까? 
1) sex 
2) age : 65+/ 65-
3) bmicat
4) educat 
5) regioncat
6) occp_new
7) ho_incm
8) marricat
9) drinkcat
10) smkcat 
11) dcat
12) pa_walk*/
/*interaction term 확인하기*/
proc phreg data=b.cohort_final;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  modvig_m*sex /rl entry=entry_age1;
strata year ;
run;

proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk modvigcat*sex /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk pa_muscle/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk pa_muscle modvigcat*dcat /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat muscle_freq2*dcat /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat muscle_freq2*dcat /rl entry=entry_age1;
strata year ;
run;


/*1)sex*/
/*1-modvig_m*/
*model3: reported health;
proc phreg data=cohort_v3;
where seniorcat=0;;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat/rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
where seniorcat=0;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk /rl entry=entry_age1;
strata year ;
*model3+muscle;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
where seniorcat=0;;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk pa_muscle/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk pa_muscle /rl entry=entry_age1;
strata year ;
/*muscle_freq2*/
*model3: reported health;
proc phreg data=cohort_v3;
where seniorcat=0;;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
*model3+aerobic;
proc phreg data=cohort_v3;
where seniorcat=0;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat /rl entry=entry_age1;
strata year ;
run;

proc phreg data=cohort_v3;
where dcat=2;
*where cancer ne 1 and  ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat/rl entry=entry_age1;
strata year ;
/*modvigcat*/
*model3: reported health;
proc phreg data=cohort_v3;
where dcat=2;
*where cancer ne 1 and  ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk /rl entry=entry_age1;
strata year ;
*model3+muscle;
proc phreg data=cohort_v3;
*where cancer ne 1 and  ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
where dcat=2;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk pa_muscle/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk pa_muscle /rl entry=entry_age1;
strata year ;
/*muscle_freq2*/
*model3: reported health;
proc phreg data=cohort_v3;
where dcat=2;
*where cancer ne 1 and  ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  /rl entry=entry_age1;
strata year;
run;
*model3+aerobic;
proc phreg data=cohort_v3;
where dcat=2;
*where cancer ne 1 and  ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat /rl entry=entry_age1;
strata year ;
run;



/*2)seniorx*/
/*1-modvig_m*/
*model3: reported health;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*death(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  modvig_m*sex  /rl entry=entry_age1;
strata year ;
run;
proc phreg data=cohort_v3;
where sex=2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvig_m  pa_walk year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  modvig_m  sex pa_walk bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat/rl entry=entry_age1;
strata year ;
run;
proc freq data=cohort_v2_2;
where seniorcat=1;
tables death*modvig_m death*modvig_m cvddeath*modvig_m;
run;

proc means data=cohort_v2_2 sum;
where seniorcat=1 and modvig_m=0;
var py1r;
proc means data=cohort_v2_2 sum;
where seniorcat=1 and modvig_m=1;
var py1r;
proc means data=cohort_v2_2 sum;
where seniorcat=1 and  modvig_m=2;
var py1r;
proc means data=cohort_v2_2 sum;
where seniorcat=1 and  modvig_m=3;
var py1r;
run;

/*modvigcat*/
*model3: reported health;
proc phreg data=cohort_v3;
where sex=1;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*death(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
where sex=2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk /rl entry=entry_age1;
strata year ;
run;

proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
where sex=1;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk pa_muscle/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk pa_muscle /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
where sex=2;
class modvigcat  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  pa_walk pa_muscle/param=ref ref=first;
model exit_age1*cvddeath(0) =  modvigcat  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  pa_walk pa_muscle /rl entry=entry_age1;
strata year ;
run;




/*muscle_freq2*/
*model3: reported health;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat sex*muscle_freq2 /rl entry=entry_age1;
strata year ;
run;

proc phreg data=cohort_v3;
where sex=1;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
where sex=2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2  year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat  /param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat  /rl entry=entry_age1;
strata year ;
run;



*model3+aerobic;
proc phreg data=cohort_v3;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*cvddeath(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat sex*muscle_freq2/rl entry=entry_age1;
strata year ;
run;

proc phreg data=cohort_v3;
where sex=1;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat /rl entry=entry_age1;
strata year ;
proc phreg data=cohort_v3;
where sex=2;
*where cancer ne 1 and cvd ne 1 and resp ne 1 and extwt ne 1 and exclude ne 1;
class muscle_freq2   year  bmicat sex educat regioncat occp_new ho_incm marricat drinkcat  smkcat dcat modvigcat/param=ref ref=first;
model exit_age1*death(0) =  muscle_freq2  sex  bmicat educat regioncat occp_new ho_incm marricat drinkcat smkcat dcat modvigcat /rl entry=entry_age1;
strata year ;
run;
