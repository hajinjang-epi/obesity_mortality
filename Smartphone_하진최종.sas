libname a "C:\Users\HajinJang\Downloads\제13차(2017년)_청소년건강행태조사_DB_SAS";

data a; set a.data17; run;
data pop17; set a.pop17; run;

proc freq data=a; table int_sp int_sp_wd int_sp_wk int_sp_item f_br f_fruit f_veg f_instnd f_fastfood f_crack f_soda f_swdrink ht wt sex age age_m grade ctype m_str pr_ht e_ses e_allwn e_lt_f e_lt_m e_edu_f e_edu_m pa_vig e_s_rcrd strata cluster w; run;
proc freq data=a; table int_sp*int_sp_wd int_sp*int_sp_wk; run; 

data a1; set a;
if int_sp eq 1 then delete;
if ht eq . or wt eq . then delete;
if f_fruit eq . then delete;
run;
proc freq data=a; table mh; run;

data a2; set a1;
/*duration*/
if int_sp_wd ne . and int_sp_wk ne . then do;
weeksp=((int_sp_wd*5)+(int_sp_wk*2))/7;
if 0<=weeksp<60 then qweeksp=1;
else if 60<=weeksp<120 then qweeksp=2;
else if 120<=weeksp<180 then qweeksp=3;
else if 180<=weeksp<240 then qweeksp=4;
else if 240<=weeksp<300 then qweeksp=5;
else if weeksp>=300 then qweeksp=6;
end;

if int_sp_wd ne . then do;
if 0<= int_sp_wd<60 then wd=1;
else if 60<=int_sp_wd<120 then wd=2;
else if 120<=int_sp_wd<180 then wd=3;
else if 180<=int_sp_wd<240 then wd=4;
else if 240<=int_sp_wd<300 then wd=5;
else if int_sp_wd>=300 then wd=6;
end;

if int_sp_wk ne . then do;
if 0<= int_sp_wk<60 then wk=1;
else if 60<=int_sp_wk<120 then wk=2;
else if 120<=int_sp_wk<180 then wk=3;
else if 180<=int_sp_wk<240 then wk=4;
else if 240<=int_sp_wk<300 then wk=5;
else if int_sp_wk>=300 then wk=6;
end;

hweeksp= weeksp/60;
hwd= int_sp_wd/60;
hwk= int_sp_wk/60;

/*content*/
if int_sp_item ne . then do;
if int_sp_item in (1,2) then content=1;
else if int_sp_item in (3,10) then content=2;
else if int_sp_item in (9,12) then content=3;
else if int_sp_item=4 then content=4;
else if int_sp_item in (5,7,8) then content=5;
else if int_sp_item=6 then content=6;
else if int_sp_item in (11,13) then content=7;
end;

/*addiction*/
if int_sp_tc ne . or int_sp_tf ne . or int_sp_ts ne . then do;
if int_sp_tc in (3,4) or int_sp_tf in (3,4) or int_sp_ts in (3,4) then prca=2;
else prca=1;
end;

/*food*/
if f_br in (1:3) then breakfast=1; else if f_br in (4:8) then breakfast=0;
if f_fruit in (1:4) then fruit=1; else if f_fruit in (5:7) then fruit=0;
if f_veg in (1:6) then veg=1; else if f_veg=7 then veg=0;
if f_instnd in (3:7) then noodle=1; else if f_instnd in (1,2) then noodle=0;
if f_fastfood in (3:7) then fastfood=1; else if f_fastfood in (1,2) then fastfood=0;
if f_crack in (3:7) then chip=1; else if f_crack in (1,2) then chip=0;

if f_soda ne . then do;
if f_soda=1 then soda=0;
else if f_soda=2 then soda=1.5;
else if f_soda=3 then soda=3.5;
else if f_soda=4 then soda=5.5;
else if f_soda=5 then soda=7;
else if f_soda=6 then soda=14;
else if f_soda=7 then soda=21;
end;
if f_swdrink ne . then do;
if f_swdrink=1 then swd=0;
else if f_swdrink=2 then swd=1.5;
else if f_swdrink=3 then swd=3.5;
else if f_swdrink=4 then swd=5.5;
else if f_swdrink=5 then swd=7;
else if f_swdrink=6 then swd=14;
else if f_swdrink=7 then swd=21;
end;

r_soda=sum(soda, swd);
if r_soda>=7 then ssb=1; else ssb=0;

k=ht/100;
bmi=round(wt/(k*k),0.000000001);

/*bmi=wt/((ht/100)**2);*/
run;

data a3; set a2;
if sex=1 then do;
*age 12;
if age_m=144 then do; pct05=15.5; pct85=23.0; pct95=25.1; end;
if age_m=145 then do; pct05=15.6; pct85=23.0; pct95=25.1; end;
if age_m=146 then do; pct05=15.6; pct85=23.1; pct95=25.2; end;
if age_m=147 then do; pct05=15.7; pct85=23.1; pct95=25.2; end;
if age_m=148 then do; pct05=15.7; pct85=23.2; pct95=25.3; end;
if age_m=149 then do; pct05=15.7; pct85=23.2; pct95=25.3; end;
if age_m=150 then do; pct05=15.8; pct85=23.3; pct95=25.4; end;
if age_m=151 then do; pct05=15.8; pct85=23.3; pct95=25.4; end;
if age_m=152 then do; pct05=15.8; pct85=23.4; pct95=25.5; end;
if age_m=153 then do; pct05=15.9; pct85=23.4; pct95=25.5; end;
if age_m=154 then do; pct05=15.9; pct85=23.5; pct95=25.6; end;
if age_m=155 then do; pct05=16.0; pct85=23.5; pct95=25.6; end;

*age 13;
if age_m=156 then do; pct05=16.0; pct85=23.6; pct95=25.7; end;
if age_m=157 then do; pct05=16.1; pct85=23.6; pct95=25.7; end;
if age_m=158 then do; pct05=16.1; pct85=23.6; pct95=25.7; end;
if age_m=159 then do; pct05=16.1; pct85=23.7; pct95=25.8; end;
if age_m=160 then do; pct05=16.2; pct85=23.7; pct95=25.8; end;
if age_m=161 then do; pct05=16.2; pct85=23.7; pct95=25.8; end;
if age_m=162 then do; pct05=16.3; pct85=23.8; pct95=25.8; end;
if age_m=163 then do; pct05=16.3; pct85=23.8; pct95=25.9; end;
if age_m=164 then do; pct05=16.3; pct85=23.8; pct95=25.9; end;
if age_m=165 then do; pct05=16.4; pct85=23.9; pct95=25.9; end;
if age_m=166 then do; pct05=16.4; pct85=23.9; pct95=26.0; end;
if age_m=167 then do; pct05=16.5; pct85=23.9; pct95=26.0; end;

*age 14;
if age_m=168 then do; pct05=16.5; pct85=23.9; pct95=26.0; end;
if age_m=169 then do; pct05=16.6; pct85=24.0; pct95=26.0; end;
if age_m=170 then do; pct05=16.6; pct85=24.0; pct95=26.1; end;
if age_m=171 then do; pct05=16.7; pct85=24.0; pct95=26.1; end;
if age_m=172 then do; pct05=16.7; pct85=24.0; pct95=26.1; end;
if age_m=173 then do; pct05=16.7; pct85=24.1; pct95=26.1; end;
if age_m=174 then do; pct05=16.8; pct85=24.1; pct95=26.1; end;
if age_m=175 then do; pct05=16.8; pct85=24.1; pct95=26.1; end;
if age_m=176 then do; pct05=16.9; pct85=24.1; pct95=26.2; end;
if age_m=177 then do; pct05=16.9; pct85=24.2; pct95=26.2; end;
if age_m=178 then do; pct05=17.0; pct85=24.2; pct95=26.2; end;
if age_m=179 then do; pct05=17.0; pct85=24.2; pct95=26.2; end;

*age 15;
if age_m=180 then do; pct05=17.0; pct85=24.2; pct95=26.2; end;
if age_m=181 then do; pct05=17.1; pct85=24.3; pct95=26.2; end;
if age_m=182 then do; pct05=17.1; pct85=24.3; pct95=26.3; end;
if age_m=183 then do; pct05=17.2; pct85=24.3; pct95=26.3; end;
if age_m=184 then do; pct05=17.2; pct85=24.3; pct95=26.3; end;
if age_m=185 then do; pct05=17.2; pct85=24.4; pct95=26.3; end;
if age_m=186 then do; pct05=17.3; pct85=24.4; pct95=26.3; end;
if age_m=187 then do; pct05=17.3; pct85=24.4; pct95=26.3; end;
if age_m=188 then do; pct05=17.4; pct85=24.4; pct95=26.4; end;
if age_m=189 then do; pct05=17.4; pct85=24.5; pct95=26.4; end;
if age_m=190 then do; pct05=17.4; pct85=24.5; pct95=26.4; end;
if age_m=191 then do; pct05=17.5; pct85=24.5; pct95=26.4; end;

*age 16;
if age_m=192 then do; pct05=17.5; pct85=24.5; pct95=26.4; end;
if age_m=193 then do; pct05=17.5; pct85=24.6; pct95=26.4; end;
if age_m=194 then do; pct05=17.6; pct85=24.6; pct95=26.5; end;
if age_m=195 then do; pct05=17.6; pct85=24.6; pct95=26.5; end;
if age_m=196 then do; pct05=17.6; pct85=24.6; pct95=26.5; end;
if age_m=197 then do; pct05=17.7; pct85=24.7; pct95=26.5; end;
if age_m=198 then do; pct05=17.7; pct85=24.7; pct95=26.5; end;
if age_m=199 then do; pct05=17.7; pct85=24.7; pct95=26.6; end;
if age_m=200 then do; pct05=17.8; pct85=24.7; pct95=26.6; end;
if age_m=201 then do; pct05=17.8; pct85=24.7; pct95=26.6; end;
if age_m=202 then do; pct05=17.8; pct85=24.8; pct95=26.6; end;
if age_m=203 then do; pct05=17.9; pct85=24.8; pct95=26.6; end;

*age 17;
if age_m=204 then do; pct05=17.9; pct85=24.8; pct95=26.6; end;
if age_m=205 then do; pct05=17.9; pct85=24.8; pct95=26.7; end;
if age_m=206 then do; pct05=18.0; pct85=24.9; pct95=26.7; end;
if age_m=207 then do; pct05=18.0; pct85=24.9; pct95=26.7; end;
if age_m=208 then do; pct05=18.0; pct85=24.9; pct95=26.7; end;
if age_m=209 then do; pct05=18.1; pct85=24.9; pct95=26.7; end;
if age_m=210 then do; pct05=18.1; pct85=25.0; pct95=26.7; end;
if age_m=211 then do; pct05=18.1; pct85=25.0; pct95=26.8; end;
if age_m=212 then do; pct05=18.1; pct85=25.0; pct95=26.8; end;
if age_m=213 then do; pct05=18.2; pct85=25.0; pct95=26.8; end;
if age_m=214 then do; pct05=18.2; pct85=25.1; pct95=26.8; end;
if age_m=215 then do; pct05=18.2; pct85=25.1; pct95=26.8; end;

*18세;
if age_m=216 then do; pct05=18.3; pct85=25.1; pct95=26.9; end;
if age_m=217 then do; pct05=18.3; pct85=25.1; pct95=26.9; end;
if age_m=218 then do; pct05=18.3; pct85=25.2; pct95=26.9; end;
if age_m=219 then do; pct05=18.3; pct85=25.2; pct95=26.9; end;
if age_m=220 then do; pct05=18.4; pct85=25.2; pct95=26.9; end;
if age_m=221 then do; pct05=18.4; pct85=25.2; pct95=26.9; end;
if age_m=222 then do; pct05=18.4; pct85=25.2; pct95=27.0; end;
if age_m=223 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=224 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=225 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=226 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=227 then do; pct05=18.6; pct85=25.4; pct95=27.0; end;
end;


if sex=2 then do;
 *age 12;
if age_m=144 then do; pct05=15.3; pct85=22.1; pct95=24.1; end;
if age_m=145 then do; pct05=15.3; pct85=22.2; pct95=24.2; end;
if age_m=146 then do; pct05=15.4; pct85=22.2; pct95=24.2; end;
if age_m=147 then do; pct05=15.4; pct85=22.3; pct95=24.3; end;
if age_m=148 then do; pct05=15.5; pct85=22.3; pct95=24.4; end;
if age_m=149 then do; pct05=15.5; pct85=22.4; pct95=24.4; end;
if age_m=150 then do; pct05=15.6; pct85=22.4; pct95=24.5; end;
if age_m=151 then do; pct05=15.6; pct85=22.5; pct95=24.5; end;
if age_m=152 then do; pct05=15.7; pct85=22.5; pct95=24.6; end;
if age_m=153 then do; pct05=15.7; pct85=22.6; pct95=24.6; end;
if age_m=154 then do; pct05=15.8; pct85=22.7; pct95=24.7; end;
if age_m=155 then do; pct05=15.8; pct85=22.7; pct95=24.7; end;

*age 13;
if age_m=156 then do; pct05=15.9; pct85=22.8; pct95=24.8; end;
if age_m=157 then do; pct05=15.9; pct85=22.8; pct95=24.8; end;
if age_m=158 then do; pct05=16.0; pct85=22.8; pct95=24.8; end;
if age_m=159 then do; pct05=16.0; pct85=22.9; pct95=24.9; end;
if age_m=160 then do; pct05=16.0; pct85=22.9; pct95=24.9; end;
if age_m=161 then do; pct05=16.1; pct85=23.0; pct95=25.0; end;
if age_m=162 then do; pct05=16.1; pct85=23.0; pct95=25.0; end;
if age_m=163 then do; pct05=16.2; pct85=23.0; pct95=25.0; end;
if age_m=164 then do; pct05=16.2; pct85=23.1; pct95=25.1; end;
if age_m=165 then do; pct05=16.3; pct85=23.1; pct95=25.1; end;
if age_m=166 then do; pct05=16.3; pct85=23.2; pct95=25.1; end;
if age_m=167 then do; pct05=16.4; pct85=23.2; pct95=25.2; end;

*age 14;
if age_m=168 then do; pct05=16.4; pct85=23.3; pct95=25.2; end;
if age_m=169 then do; pct05=16.5; pct85=23.3; pct95=25.2; end;
if age_m=170 then do; pct05=16.5; pct85=23.3; pct95=25.2; end;
if age_m=171 then do; pct05=16.6; pct85=23.3; pct95=25.3; end;
if age_m=172 then do; pct05=16.6; pct85=23.4; pct95=25.3; end;
if age_m=173 then do; pct05=16.6; pct85=23.4; pct95=25.3; end;
if age_m=174 then do; pct05=16.7; pct85=23.4; pct95=25.3; end;
if age_m=175 then do; pct05=16.7; pct85=23.5; pct95=25.3; end;
if age_m=176 then do; pct05=16.8; pct85=23.5; pct95=25.4; end;
if age_m=177 then do; pct05=16.8; pct85=23.5; pct95=25.4; end;
if age_m=178 then do; pct05=16.9; pct85=23.6; pct95=25.4; end;
if age_m=179 then do; pct05=16.9; pct85=23.6; pct95=25.4; end;

*age 15;
if age_m=180 then do; pct05=16.9; pct85=23.6; pct95=25.4; end;
if age_m=181 then do; pct05=17.0; pct85=23.6; pct95=25.4; end;
if age_m=182 then do; pct05=17.0; pct85=23.6; pct95=25.5; end;
if age_m=183 then do; pct05=17.0; pct85=23.7; pct95=25.5; end;
if age_m=184 then do; pct05=17.1; pct85=23.7; pct95=25.5; end;
if age_m=185 then do; pct05=17.1; pct85=23.7; pct95=25.5; end;
if age_m=186 then do; pct05=17.1; pct85=23.7; pct95=25.5; end;
if age_m=187 then do; pct05=17.2; pct85=23.7; pct95=25.5; end;
if age_m=188 then do; pct05=17.2; pct85=23.7; pct95=25.5; end;
if age_m=189 then do; pct05=17.2; pct85=23.7; pct95=25.5; end;
if age_m=190 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=191 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;

*age 16;
if age_m=192 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=193 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=194 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=195 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=196 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=197 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=198 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=199 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=200 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=201 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=202 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=203 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;

*age 17;
if age_m=204 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=205 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=206 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=207 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=208 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=209 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=210 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=211 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=212 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=213 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=214 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=215 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;

*age 18;
if age_m=216 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=217 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=218 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=219 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=220 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=221 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=222 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=223 then do; pct05=17.6; pct85=23.6; pct95=25.5; end;
if age_m=224 then do; pct05=17.6; pct85=23.6; pct95=25.4; end;
if age_m=225 then do; pct05=17.6; pct85=23.6; pct95=25.4; end;
if age_m=226 then do; pct05=17.6; pct85=23.6; pct95=25.4; end;
if age_m=227 then do; pct05=17.7; pct85=23.6; pct95=25.4; end;
end;

if bmi ne . and age ne . and ht ne . and wt ne . and pct95 ne . and pct85 ne . and pct05 ne . then do;
if bmi>=pct95 then g_bmi=4; /*비만*/
else if pct85<=bmi<pct95 then g_bmi=3; /*과체중*/
else if pct05<=bmi<pct85 then g_bmi=2;
else if bmi<pct05 then g_bmi=1; /*저체중*/
end;

if g_bmi in (1,2,3) then obese=0;
else if g_bmi=4 then obese=1;

run;

data a4; set a3;

if age ne . then n_age=age;
if age eq . then do;
if grade=1 then n_age=13;
else if grade=2 then n_age=14;
else if grade=3 then n_age=15;
else if grade=4 then n_age=16;
else if grade=5 then n_age=17;
else if grade=6 then n_age=18;
end;

if grade in (1,2,3) then mdh=0; /*중학생*/
else if grade in (4,5,6) then mdh=1; /*고등학생*/

if ctype="대도시" then city1=3;
else if ctype="중소도시" then city1=2;
else city1=1;

if pr_ht ne . then do;
if pr_ht in (4,5) then n_pr_ht =1;
else if pr_ht =3 then n_pr_ht =2;
else if pr_ht =2 then n_pr_ht =3;
else if pr_ht =1 then n_pr_ht =4;
end;

if e_ses ne . then do;
if e_ses in (4,5) then ce_ses=1;
else if e_ses=3 then ce_ses=2;
else if e_ses in (1,2) then ce_ses=3;
end;

if m_str ne . then do;
if m_str in (4,5) then stress=1;
else if m_str=3 then stress=2;
else if m_str in (1,2) then stress=3;
end;

if e_lt_f=1 and e_lt_m=1 then parents=1;
else if (e_lt_f=1 and e_lt_m ne 1) or (e_lt_f ne 1 and e_lt_m =1) then parents=2;
else parents=3;

if e_edu_f in (4,9999) then e_edu_f=0;
if e_edu_m in (4,9999) then e_edu_m=0;
if e_edu_f>=e_edu_m then e_parents=e_edu_f;
else if e_edu_f<e_edu_m then e_parents=e_edu_m;
e_parents_1=e_parents+1;
/* e_parents_1: 1= unknown, 2=중졸이하, 3=고졸 4= 대학교 졸업 이상 */
if e_parents_1 in (2,3) then e_par=1; 
else if e_parents_1=4 then e_par=2;
else if e_parents_1=1 then e_par=3;
/* e_par: 1=고졸이하, 2=대졸이상, 3=unknown */

/*pa*/
if pa_tot=1 then tot=0;
else if pa_tot in (2:7) then tot=1; 
else if pa_tot=8 then tot=2; 

if pa_vig=1 then vig=0;
else if pa_vig in (2,3) then vig=1;
else if pa_vig in (4,5,6) then vig=2; 

if tot=0 and vig=0 then pa=1;
else if tot=0 and vig=1 then pa=2;
else if tot=1 and vig=0 then pa=2;
else if tot=1 and vig=1 then pa=2;
else if tot=2 or vig=2 then pa=3;

if e_allwn=1 then money=1;
else if e_allwn in (2:5) then money=2;
else if e_allwn in (6:16) then money=3;


if e_s_rcrd in (4,5) then e_s_rcrd=4;

if e_s_rcrd ne . then do;
if e_s_rcrd=1 then record=4;
else if e_s_rcrd=2 then record=3;
else if e_s_rcrd=3 then record=2;
else if e_s_rcrd=4 then record=1;
end;

run;


/****************************************************************************************/

/*table1*/
%macro table1(var);
proc surveyfreq data=a4 total=pop17 nomcar;
strata strata;
cluster cluster;
weight w;
table qweeksp*&var./row;
run;
%mend;

%table1(sex);
%table1(mdh);
%table1(city1);
%table1(n_pr_ht);
%table1(ce_ses);
%table1(stress);
%table1(pa);
%table1(parents);
%table1(e_par);
%table1(money);
%table1(record);
%table1(prca);
%table1(content);
%table1(obese);
%table1(prca);
%table1(e_s_rcrd);

/*table2*/
%macro dur(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref="1") sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = qweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca content money/clodds;
domain obese;
run;
%mend;

%dur(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%dur(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%dur(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%dur(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*p-trend*/
%macro dur_pt(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = qweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca content money/clodds;
domain obese;
run;
%mend;

%dur_pt(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur_pt(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur_pt(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur_pt(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%dur_pt(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%dur_pt(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%dur_pt(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*p-interaction*/
%macro dur_pi(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref="1") sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = qweeksp*obese obese qweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca content money/clodds;
run;
%mend;

%dur_pi(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur_pi(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur_pi(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%dur_pi(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%dur_pi(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%dur_pi(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%dur_pi(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*table3*/
%macro con(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") money(ref="1") record(ref="1") prca(ref="1") content(ref="1")/param=ref;
model &out.(event="1") =content hweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca money/clodds;
domain obese;
run;
%mend;

%con(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%con(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%con(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%con(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%con(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%con(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%con(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*p-interaction*/
%macro con_pi(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") money(ref="1") record(ref="1") prca(ref="1") content(ref="1")/param=ref;
model &out.(event="1") =content*obese obese content hweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca money/clodds;
run;
%mend;

%con_pi(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%con_pi(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%con_pi(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%con_pi(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%con_pi(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%con_pi(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%con_pi(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);



/****************************/
/*suppl 1*/
proc surveymeans data=a4 nomcar total=pop17 median q1 q3;
strata strata;
cluster cluster;
weight w;
domain obese*sex*content;
var weeksp;
run;
proc surveymeans data=a4 nomcar total=pop17 median q1 q3;
strata strata;
cluster cluster;
weight w;
domain obese*sex;
var weeksp;
run;
proc surveymeans data=a4 nomcar total=pop17 median q1 q3;
strata strata;
cluster cluster;
weight w;
domain obese*sex*mdh*content;
var weeksp;
run;
proc surveymeans data=a4 nomcar total=pop17 median q1 q3;
strata strata;
cluster cluster;
weight w;
domain obese*sex*mdh;
var weeksp;
run;

/*suppl 2*/
proc surveyfreq data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
table content/row;
table content*sex/row;
table content*mdh/row;
table content*city1/row;
table content*ce_ses/row;
table content*parents/row;
table content*e_par/row;
table content*money/row;
table content*stress/row;
table content*n_pr_ht/row;
table content*pa/row;
table content*record/row; /*1=하 2=중 3=중상 4=상*/
table content*prca/row;
table content*obese/row;
run;

/*suppl 3*/
/*weekday*/
%macro wd(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref="1") sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = wd wk sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca content money/clodds;
domain obese;
run;
%mend;

%wd(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wd(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wd(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wd(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%wd(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%wd(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%wd(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*weekend*/
%macro wk(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref="1") sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = wk wd sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca content money/clodds;
domain obese;
run;
%mend;

%wk(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wk(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wk(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wk(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%wk(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%wk(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%wk(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*p-trend*/
%macro wd_p(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = wd wk sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. prca content money/clodds;
domain obese;
run;
%mend;

%wd_p(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wd_p(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wd_p(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%wd_p(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%wd_p(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%wd_p(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%wd_p(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);


/*suppl 4*/
%macro addu(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref="1") sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = qweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. content money/clodds;
domain obese*prca;
run;
%mend;

%addu(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%addu(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%addu(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%addu(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*p-trend*/
%macro addu_pt(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = qweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. content money/clodds;
domain obese*prca;
run;
%mend;

%addu_pt(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu_pt(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu_pt(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu_pt(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%addu_pt(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%addu_pt(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%addu_pt(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);

/*p-interaction*/
%macro addu_pi(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref="1") sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") record(ref="1") prca(ref="1") content(ref="1") money(ref="1")/param=ref;
model &out.(event="1") = prca*qweeksp qweeksp prca sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. content money/clodds;
domain obese;
run;
%mend;

%addu_pi(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu_pi(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu_pi(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%addu_pi(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%addu_pi(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%addu_pi(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%addu_pi(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);




/*suppl 5*/
/*sex / mdh / ce_ses / e_par / stress*/
proc freq data=a4; table mdh ce_ses e_par stress; run;

%macro nonobe(strat,strat_covar,out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") money(ref="1") record(ref="1") prca(ref="1") content(ref="1")/param=ref;
model &out.(event="1") =hweeksp &strat_covar. content grade city1 n_pr_ht pa parents record &covar. money prca/clodds;
domain obese*&strat.;
run;
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") money(ref="1") record(ref="1") prca(ref="1") content(ref="1")/param=ref;
model &out.(event="1") =hweeksp*&strat. &strat. hweeksp &strat_covar. content grade city1 n_pr_ht pa parents record &covar. money prca/clodds;
domain obese;
run;
%mend;

/*sex*/
%nonobe(sex,ce_ses e_par stress,breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(sex,ce_ses e_par stress,fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(sex,ce_ses e_par stress,veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(sex,ce_ses e_par stress,noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%nonobe(sex,ce_ses e_par stress,fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%nonobe(sex,ce_ses e_par stress,chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%nonobe(sex,ce_ses e_par stress,ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);
/*mdh*/
%nonobe(mdh,sex ce_ses e_par stress,breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(mdh,sex ce_ses e_par stress,fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(mdh,sex ce_ses e_par stress,veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(mdh,sex ce_ses e_par stress,noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%nonobe(mdh,sex ce_ses e_par stress,fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%nonobe(mdh,sex ce_ses e_par stress,chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%nonobe(mdh,sex ce_ses e_par stress,ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);
/*ce_ses*/
%nonobe(ce_ses,sex e_par stress,breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(ce_ses,sex e_par stress,fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(ce_ses,sex e_par stress,veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(ce_ses,sex e_par stress,noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%nonobe(ce_ses,sex e_par stress,fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%nonobe(ce_ses,sex e_par stress,chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%nonobe(ce_ses,sex e_par stress,ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);
/*e_par*/
%nonobe(e_par,sex ce_ses stress,breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(e_par,sex ce_ses stress,fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(e_par,sex ce_ses stress,veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(e_par,sex ce_ses stress,noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%nonobe(e_par,sex ce_ses stress,fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%nonobe(e_par,sex ce_ses stress,chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%nonobe(e_par,sex ce_ses stress,ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);
/*stress*/
%nonobe(stress,sex ce_ses e_par,breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(stress,sex ce_ses e_par,fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(stress,sex ce_ses e_par,veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%nonobe(stress,sex ce_ses e_par,noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%nonobe(stress,sex ce_ses e_par,fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%nonobe(stress,sex ce_ses e_par,chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%nonobe(stress,sex ce_ses e_par,ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);



/*suppl 6*/
%macro adcon(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") money(ref="1") record(ref="1") prca(ref="1") content(ref="1")/param=ref;
model &out.(event="1") =content hweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. money/clodds;
domain obese*prca;
run;
%mend;

%adcon(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%adcon(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%adcon(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%adcon(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%adcon(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%adcon(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%adcon(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);


%macro adcon_pi(out,covar);
proc surveylogistic data=a4 nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref="1") grade(ref="1") city1(ref="1") n_pr_ht(ref="1") ce_ses(ref="1") stress(ref="1") pa(ref="1") parents(ref="1") e_par(ref="1") money(ref="1") record(ref="1") prca(ref="1") content(ref="1")/param=ref;
model &out.(event="1") =content*prca prca content hweeksp sex grade city1 n_pr_ht ce_ses stress pa parents e_par record &covar. money/clodds;
domain obese;
run;
%mend;

%adcon_pi(breakfast,f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%adcon_pi(fruit,f_br f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda);
%adcon_pi(veg,f_br f_fruit f_instnd f_crack f_fastfood  f_swdrink f_soda);
%adcon_pi(noodle,f_br f_fruit f_veg f_crack f_fastfood  f_swdrink f_soda);
%adcon_pi(fastfood,f_br f_fruit f_veg f_crack f_instnd  f_swdrink f_soda);
%adcon_pi(chip,f_br f_fruit f_veg f_fastfood f_instnd  f_swdrink f_soda);
%adcon_pi(ssb,f_br f_fruit f_veg f_fastfood f_instnd  f_crack);


proc surveyfreq data=a4 total=pop17 nomcar  ;
strata strata;
weight w;
cluster cluster;
table sex*obese/row; run;
