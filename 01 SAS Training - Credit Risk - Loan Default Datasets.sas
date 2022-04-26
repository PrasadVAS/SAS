/* TO CHECK THE SAS VERSION AND SAS MODULES */
PROC SETINIT; RUN;



/* DATA IMPORT */
/* Load XLSX file using Import Procedure */
PROC IMPORT 
DATAFILE="/home/u845941/data/Loan_default_for_SAS_Training.xlsx"
OUT=LOAN_DF 
DBMS=XLSX REPLACE;
 
  SHEET="Jan2021_Data";
  GETNAMES=YES; 
  DATAROW=2;
  /* RANGE="range-name"; */
RUN;
 /*REPLACE;*/

/* IMPORTING CSV FILE  */
proc import datafile = '/home/u845941/data/Loan_Default_train_ctrUa4K.csv'
 out = work.LOAN_DF_CSV
 dbms = CSV
 REPLACE
 ;
run;

/* specifying a library */ 
libname in '/home/u845941/data';

/* importing a text file to a permanent dataset in a permanent library */ 
proc import datafile = '/home/u845941/data/Loan_Default_train_ctrUa4K_tab_text.txt'
 out = in.LOAN_DF_TXT
 dbms = dlm
 replace;
 delimiter = '09'x;
run;

/* PRINT FIRST 10 OBSERVATIONS */
PROC PRINT DATA = WORK.LOAN_DF (OBS = 10);
RUN;

/* PRINT 10 OBSERVATIONS FROM 21ST OBSERVATION */
PROC PRINT DATA = WORK.LOAN_DF (FIRSTOBS=21 OBS=31);
RUN;



/* DATA PROFILING AND AUDIT */

/* FIND THE NUMBER OF OBSERVATIONS, COLUMNS,  NAMES AND TYPES OF COLUMNS */
PROC CONTENTS DATA = LOAN_DF POSITION OUT=LOAND_DF_CONTENTS; RUN;

/*
A format is a type of SAS language element that applies a pattern to or executes instructions 
for a data value to be displayed or written as output. Types of formats correspond to the type 
of data: numeric, character, date, time, or timestamp. The ability to create user-defined formats 
is also supported. Examples of SAS formats are BINARY, DATE, and WORDS. The WORDS22. format, 
which converts numeric values to their equivalent in words, writes the numeric value 692 as 
six hundred ninety-two.
*/


/*
Definition of Informats

An informat is a type of SAS language element that applies a pattern to or executes instructions 
for a data value to be read as input. Types of informats correspond to the data's type: 
numeric, character, date, time, or timestamp. The ability to create user-defined informats 
is also supported. Examples of SAS informats are BINARY, DATE. and COMMA. For example, 
the following value contains a dollar sign and commas: $1,000,000
To remove the dollar sign ($) and commas (,) before storing the numeric value 1000000 in a variable,
 read this value with the COMMA11. informat.
Unless you explicitly define a variable first, SAS uses the informat to determine 
whether the variable is numeric or character. SAS also uses the informat to determine the 
length of character variables.

*/

DATA Customer_Details;
Informat Account_Number 5. CustomerName $10. City $10. DateOfBirth DDMMYY10. Acc_Balance 10. Acc_OpenDate DATE9.;
Input @1Account_Number 5. @7CustomerName $10. @20City $10. @32DateOfBirth DDMMYY10. @45Acc_Balance COMMA10. @55Acc_OpenDate DATE9.;
Format DateOfBirth DATE9. Acc_OpenDate DDMMYY10.;
DATALINES;
12345 Nikhil 	Delhi 		01/01/1990 45000.45 20JAN2000
12346 Abhijit 	Kolkata 	05/11/1991 150000.1 20NOV2020
12347 Puja 		Mumbai 		08/12/1970 70000.45 20FEB2018
12348 Sourav 	Bangalore 	14/05/2010 50000.98 20MAR2016
12349 Sonam 	Pune 		04/10/2001 45000.00 20JAN2021
run;

PROC PRINT DATA=Customer_Details;
run;

/* DISTRIBUTION DETAILS OF TWO NUMERIC VARIABLES */
TITLE 'MEANS OF TWO NUMERIC VARIABLES';
PROC MEANS DATA = LOAN_DF;
VAR ApplicantIncome LoanAmount;
RUN;

/* DISTRIBUTION DETAILS OF ALL NUMERIC VARIABLES */
TITLE 'MEANS OF ALL NUMERIC VARIABLES';
PROC MEANS DATA = LOAN_DF N NMISS MIN P1 P25 MEDIAN  MEAN  P95 P99 MAX STDDEV;
VAR _NUMERIC_;
RUN;

/* CAPTURE THE DISTRIBUTION DETAILS OF ALL NUMERIC VARIABLES IN TO A DATSET */
TITLE 'MEANS OF ALL NUMERIC VARIABLES';
PROC MEANS DATA = LOAN_DF;
VAR _NUMERIC_;
OUTPUT OUT = LOAD_DF_MEANS;
RUN;

PROC TRANSPOSE DATA=WORK.load_DF_means OUT=WORK.LOAD_DF_MEANS_FINAL;
* ID _STAT_;
/* ID _STAT_ */
RUN;

/* TRANSPOSE THE OUTPUT DATASET OF MEANS PROCEDURE SO AS TO GET THE VARIABLE DISTRIBUTION
DETAILS ACROSS COLUMNS */
PROC TRANSPOSE DATA=WORK.load_DF_means OUT=WORK.LOAD_DF_MEANS_FINAL;
ID _STAT_;
RUN;

DATA LOAD_DF_MEANS_FINAL;
SET LOAD_DF_MEANS_FINAL (RENAME = (_NAME_ = NAME ));
RENAME _LABEL_ = LABEL ;
RUN;


DATA LOAD_DF_MEANS_FINAL2;
SET  LOAD_DF_MEANS_FINAL(WHERE = (NAME NOT IN ('_TYPE_','_FREQ_')));
RUN;

DATA LOAD_DF_MEANS_FINAL1;
SET  LOAD_DF_MEANS_FINAL;
IF NAME NOT IN ('_TYPE_','_FREQ_') ;
RUN;

* https://www.listendata.com/2016/04/send-sas-output-to-excel.html ;
	
proc export data=LOAD_DF_MEANS_FINAL1
            outfile="/home/u845941/data/MEANS_OF_LOANS_DATA_output.xls" DBMS = XLS;
      run;

* FOR CHARACTER VARIABLES' DISTRIBUTION 'FREQUENCY' PROCEDURE IS THE BEST 
https://stats.oarc.ucla.edu/sas/output/proc-freq/
;

PROC FREQ DATA=LOAN_DF (DROP = LOAN_ID) ;
 TABLES _CHAR_/MISSING MISSPRINT NOCUM NOPERCENT;
RUN;

* CROSS TABULATION OF TWO VARIABLES GENDER AND MARRIED;
PROC FREQ DATA=LOAN_DF (DROP = LOAN_ID) ;
 TABLES GENDER * MARRIED/MISSING MISSPRINT NOCUM NOPERCENT;
RUN;


* CROSS TABULATION OF TWO VARIABLES GENDER AND MARRIED IN A TABLE;
PROC FREQ DATA=LOAN_DF (DROP = LOAN_ID) ;
 TABLES GENDER * MARRIED/MISSING MISSPRINT NOCUM NOPERCENT LIST;
RUN;


PROC SORT DATA = LOAN_DF OUT = LOAN_DF_SORT; BY DESCENDING LOCATION; RUN;


* CROSS TABULATION OF TWO VARIABLES GENDER AND MARRIED IN A TABLE
IN TO AN OUTPUT DATASET
;
PROC FREQ DATA=LOAN_DF (DROP = LOAN_ID) ;
 TABLES GENDER * MARRIED/out=freqcnt outexpect sparse;
 by location; 
 RUN;

out=freqcnt outexpect sparse

* LOOKING AT THE DISTRIBUTION OF NUMERIC VARIABLE IN DETAIL
FOR APPLICANT INCOME 'UNIVARIATE' PROCEDURE IS THE BEST;
* REFERENCE LINK FOR ANNOTATED OUTPUT
https://stats.oarc.ucla.edu/sas/output/proc-univariate/
;
PROC UNIVARIATE DATA = LOAN_DF PLOT normal;
VAR APPLICANTINCOME;
RUN;


PROC UNIVARIATE DATA = LOAN_DF PLOT normal;
VAR APPLICANTINCOME;
where APPLICANTINCOME < 24000;
RUN;

* COMPARE THE BOXPLOTS BY GENDER FOR APPLICANT INCOME 
FOR USING BY STATEMENT FOR ANY VARIABLE, THE DATA HAS TO BE SORTED;
PROC SORT DATA = LOAN_DF;
BY GENDER;
RUN;

PROC UNIVARIATE DATA = LOAN_DF PLOT normal ;
VAR APPLICANTINCOME;
BY GENDER;
RUN;

* how to check if a variable is following normal distribution;
* https://www.statology.org/shapiro-wilk-test-in-sas/;


* PROC SUMMARY ANNOTATED OUTPUT;
* https://www.9to5sas.com/proc-summary-in-sas/;

PROC SUMMARY DATA=work.LOAN_DF print;
VAR APPLICANTINCOME CoapplicantIncome;
OUTPUT OUT=LOAN_DF_SUMMARY_OP;
RUN;


PROC SUMMARY DATA=work.LOAN_DF;
VAR APPLICANTINCOME CoapplicantIncome;
class gender;
OUTPUT OUT=LOAN_DF_SUMMARY_OP N=N NMISS=NMISS PRT=PRT VAR=VAR MEAN=MEAN
 RANGE=RANGE STD=STD MIN=MIN MAX=MAX/AUTONAME ;
RUN;


PROC SUMMARY DATA=work.LOAN_DF;
VAR APPLICANTINCOME CoapplicantIncome;
class gender;
OUTPUT OUT=LOAN_DF_SUMMARY_OP N= NMISS= PRT= VAR= MEAN=
 RANGE= STD= MIN= MAX=/AUTONAME ;
RUN;



* ASSIGNMENT 1
1. PRINT LAST 10 OBSERVATIONS 
2. KEEP ONLY RELEVANT FIELDS (NAME, TYPE, LABEL) IN LOAD_DATA_CONTENTS dataset 
3. HOW IS EXPECTED FREQUENCY IN FREQ PROCEDURE? 
4. What is the difference between PROC MEANS, SUMMARY AND UNIVARIATE? give an example
https://www.toolbox.com/tech/big-data/question/proc-summary-vs-proc-means-042804/
https://amadeus.co.uk/tips/basic-differences-between-proc-means-and-proc-summary/#:~:text=The%20main%20difference%20concerns%20the,results%20to%20the%20output%20window.


;

/* DATA SUBSET */
* WHAT ARE DATASTEP OPTIONS? IT'S IMPORTANT TO BE AWARE OF THEM ;
* http://webhome.auburn.edu/~carpedm/courses/stat6110/notes/module3/Module3.pdf;
* https://www.listendata.com/2013/09/sas-where-statement-and-dataset-options.html;


*9	View last 20 observations;
DATA LAST_20;
SET LOAN_DF NOBS=N; 
/* nobs is a SAS automatic variable CONTAINING the number of records in the data set */
if _N_ > N-20; /* _N_ IS THE AUTOMATIC VARIABLE FOR OBSERVATION OR ROW NUMBER */
RUN;
PROC PRINT DATA = LAST_20;
RUN;

/* creating user data  */

data a;
do i = 1 to 10 ;
a=1;
output;
end;
run;

proc sort data = a out=a_dup nodupkey; by a;  run;

proc sort data = a out=a_dup nodup; by a;  run;


*10	remove duplicates in "LOAN_DF";
PROC SORT DATA=LOAN_DF OUT=LOAN_DF_NO_DUP NODUP; by loan_id ; run;


PROC PRINT DATA=LOAN_DF_NO_DUP;RUN;

*11	remove duplicates in "LOAN_DF" by Gender; 
PROC SORT DATA=LOAN_DF OUT=LOAN_DF_NO_DUP NODUP; BY gender ; 
run;


PROC PRINT DATA=LOAN_DF_NO_DUP;RUN; 

*12	Sort "LOAN_DF" by Loan_Amount in the descending order;
PROC SORT DATA=LOAN_DF OUT= LOAN_DF_LOANAMT_DESC; BY DESCENDING LoanAmount; RUN;
PROC PRINT DATA = LOAN_DF_LOANAMT_DESC;  RUN; 

*13	find out the number of missing values in each variable; *FREQUENCY;
PROC FREQ DATA=LOAN_DF;
 TABLES _CHAR_/MISSING MISSPRINT NOCUM NOPERCENT;
 TABLES _NUMERIC_/MISSING MISSPRINT NOCUM NOPERCENT;
RUN;

*13	find out the number of missing values in each variable;
PROC FORMAT;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
PROC FREQ DATA=LOAN_DF (drop = loan_id);
 FORMAT _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
 TABLES _CHAR_/MISSING MISSPRINT NOCUM NOPERCENT;
 FORMAT _NUMERIC_ missfmt.;
 TABLES _NUMERIC_/MISSING MISSPRINT NOCUM NOPERCENT;
RUN;

/*14	Create a new dataframe "checking" with condition of 
Location = Rural and Applicant Income > 3000 + 
keeping only Loan_ID, ApplicantIncome, Dependents, Education, Loan Status 
in the reverse order of the variables listed*/

DATA CHECKING; 
SET LOAN_DF (WHERE = ( ApplicantIncome > 3000 AND Location = 'Rural')) ;
keep Loan_Status Education Dependents ApplicantIncome Loan_ID ;
RUN;

DATA CHECKING1 (keep =  Loan_Status Education Dependents ApplicantIncome Loan_ID); 
* RETAIN IS USED TO ORDER THE NAMES OF THE COLUMNS IN A DATASET 
IT'S PLACED BETWEEN DATA AND SET STATEMENTS;
RETAIN Loan_Status Education Dependents ApplicantIncome Loan_ID;
SET LOAN_DF (WHERE = ( ApplicantIncome > 3000 AND Location = 'Rural')) ;
RUN;

*15	Delete columns ApplicantIncome and Dependents from the dataframe "checking";
DATA CHECKING;
SET CHECKING;
DROP ApplicantIncome Dependents;
RUN;

*15	Delete columns ApplicantIncome and Dependents from the dataframe "checking";
DATA CHECKING;
RETAIN Education ;
SET CHECKING (DROP = ApplicantIncome Dependents);
*DROP ApplicantIncome ;

RUN;

* RETAIN IS ALSO USED FOR CUMULATIVE SUM CALCULATION IN A DATASET ;
* what % of customers contribute to 70% of Total Loan amount ;

* taking a random sample of 5 percent for understanding the logic and do approximations;
data loan_df_10obs (keep = loan_id loan_status LoanAmount gender);
set loan_df (where = (loan_status = "Y")); /* why loan_status = "Y"? */
*if ranuni(27271) <= (0.05); /* specify the percentage */
run;

proc sort data = loan_df_10obs ; 
by descending LoanAmount ;
run;

data work.loan_df_10obs_cum_sum;
	set work.loan_df_10obs nobs = n;
 
	retain cumulative_LoanAmount;
 
	if _n_ = 1 then cumulative_LoanAmount = LoanAmount;
	else cumulative_LoanAmount = sum(cumulative_LoanAmount, LoanAmount);

* displaying the value in the log window while executing the data step
useful for debugging the code;
if _n_ = n then put 'Total Loan Amount : ' cumulative_LoanAmount=;

run;

data work.loan_df_10obs_cum_sum;
set loan_df_10obs_cum_sum ;
format cum_pct_loan_amt percent10.2;
cum_pct_loan_amt = cumulative_LoanAmount/59400;
 
run;

proc univariate data = loan_df_10obs_cum_sum plot;
var cum_pct_loan_amt;
run;





* FUNCTIONS
* https://www.tutorialspoint.com/sas/sas_functions.htm;
*Function Categories
Depending on their usage, the functions in SAS are categorised as below.

1. Mathematical
2. Date and Time
3. Character
4. Truncation
5. Miscellaneous


* Mathematical Functions
These are the functions used to apply some mathematical calculations on the variable values ;



DATA LOAN_DF_21;
SET LOAN_DF;
LOG_APP_INCOME = LOG(APPLICANTINCOME);
SQRT_APP_INCOME = SQRT(ApplicantIncome);
INV_APP_INCOME =  1/ApplicantIncome; *INV(ApplicantIncome);
FAMILY_INCOME = ApplicantIncome + CoApplicantIncome;
min_income = min(ApplicantIncome, CoApplicantIncome)

/* min, max, sqrt, */

RUN;

* Date and Time Functions
These are the functions used to process date and time values;

data date_functions;
INPUT @1 date1 date9. @11 date2 date9.;
format date1 date9.  date2 date9.;

/* Get the interval between the dates in years*/
Years_ = INTCK('YEAR',date1,date2);

/* Get the interval between the dates in months*/
months_ = INTCK('MONTH',date1,date2);

/* Get the week day from the date*/
weekday_ =  WEEKDAY(date1);

/* Get Today's date in SAS date format */
format today_ date9. ;
today_ = TODAY();

/* Get current time in SAS time format */
format time_ datetime18.;
time_ = time();
DATALINES;
21OCT2000 16AUG1998
01MAR2009 11JUL2012
;
proc print data = date_functions noobs;
run;

/* CHARACTER FUNCTIONS */
* https://www.listendata.com/2014/12/sas-character-functions.html;
* These are the functions used to process character or text values;

data character_functions;

/* Convert the string into lower case */
lowcse_ = LOWCASE('HELLO');
  
/* Convert the string into upper case */
upcase_ = UPCASE('hello');
  
/* Reverse the string */
reverse_ = REVERSE('Hello');
  
/* Return the nth word */
nth_letter_ = SCAN('Learn SAS Now',2);

/* trim, concat, compress */
run;

proc print data = character_functions noobs;
run;

*Truncation Functions
These are the functions used to truncate numeric values;

data trunc_functions;

/* Nearest greatest integer */
ceil_ = CEIL(11.85);
  
/* Nearest greatest integer */
floor_ = FLOOR(11.85);
  
/* Integer portion of a number */
int_ = INT(32.41);
  
/* Round off to nearest value */
round_ = ROUND(5621.78,1);
run;

proc print data = trunc_functions noobs;
run;

* MISCELAANEOUS FUNCTIONS 
data misc_functions;

/* Nearest greatest integer */
state2=zipstate('01040');
 
/* Amortization calculation */
payment = mort(50000, . , .10/12,30*12);

proc print data = misc_functions noobs;
run;

***********************************************
***********************************************
***********************************************;

*23	Divide bins of family income in to 1000-2000, 2001-3000, 3001-5000, 5001-7000, 7000+;
PROC FORMAT;
VALUE BINS
	LOW -< 1000 = "1000-"
	1000 -< 2000 = "1001-2000"
	2001 -< 3000 = "2001 - 3000"
	3001 -< 5000 = "3001 - 5000"
	5001 -< 7000 = "5001 - 7000"
	7001 - HIGH = "7000+";
RUN;
DATA LOAN_DF_BINS;
SET LOAN_DF_21;
FORMAT FAMILY_INCOME BINS.; *Assign BINS format to Family_Income variable;
RUN;


/* is the applicant major income earner in the house hold? IF SO, HOW MANY applicants are such earners? */
data LOAN_DF_21;
SET LOAN_DF_21;
if ApplicantIncome > CoApplicantIncome then major_income_earner = 'Yes'; else major_income_earner = 'No';

* LOGICAL OPERATOR;
major_income_earner_true = (ApplicantIncome > CoApplicantIncome);

run;
proc freq data = LOAN_DF_21;
tables major_income_earner major_income_earner*major_income_earner_true/list missing;
run;


*25	are Education, Dependents, Genders drivers of loan_status decision by banks
https://stats.oarc.ucla.edu/sas/output/proc-freq/

Perform Cross Tabulation between Education and Loan Status;

proc FREQ data = LOAN_DF ;
tables Education * Loan_Status  / nocol norow nopercent list expected chisq;   
run;

*26	Perform Cross Tabulation between ApplicantIncome and Loan Status;
proc FREQ data = LOAN_DF ;
tables ApplicantIncome * (Loan_Status)  / nocol norow nopercent list expected chisq;   
run;

*27	Perform Cross Tabulation between Dependents and Loan Status;
proc FREQ data = LOAN_DF ;
tables Dependents * (Loan_Status)  / nocol norow nopercent list expected chisq;   
run;

****************
CREATE ASSOCIATION VARIABLES
;

DATA LOAN_DF_ASSOCIATION;
SET LOAN_DF;
IF GENDER = '' THEN GENDER = 'MIS';
IF MARRIED = '' THEN MARRIED = 'MIS';
GENDER_MARITAL_STATUS = CAT(GENDER,'_', MARRIED);
RUN;


*27	Perform Cross Tabulation between Dependents and Loan Status;
proc FREQ data = LOAN_DF_ASSOCIATION ;
tables GENDER_MARITAL_STATUS * (Loan_Status)  / nocol norow nopercent list expected chisq;   
run;


*27	Perform Cross Tabulation between Dependents and Loan Status;
proc FREQ data = LOAN_DF_ASSOCIATION ;
tables GENDER * MARRIED * (Loan_Status)  / nocol norow nopercent list expected chisq;   
run;

*24	Create dummy variables  based on
	Gender
	Dependents
	Education;

/*16	Create a new data frame of 100,000 obesrbations and 20 variables of your choice using random numbers   
name the dataframe as "random";*/

DATA RANDOM;
/*INPUT A B C;*/
DO I = 1 TO 10 by 0.5;
A= RANUNI(6325);
B = A+10;
C = A+B;
*OUTPUT;
put i= a=  b= c=;
END;
put 'end of the loop: 'i= a=  b= c=;
RUN;

/* SAS ARRAYS
https://www.tutorialspoint.com/sas/sas_arrays.htm
;


DATA RANDOM;
/*INPUT A B C;*/
ARRAY SALE[20] ;

DO I = 1 TO 10;

DO J = 1 TO 20;
SALE[J] = RANUNI(6525);
END;

OUTPUT;

END;
RUN;




/* Concatenating and Joining Datasets */

*https://www.tutorialspoint.com/sas/sas_merging_data_sets.htm;

DATA A;
INPUT A B C;
CARDS;
-1 3 .
1 2 10
2 3 12
;
RUN;


DATA B;
INPUT A C D;
CARDS;
1 5 3
2 7 4
5 6 8
;
RUN;


DATA C;
SET A B;
RUN;

/* DATASETS USED FOR JOINING USING DATA STEP NEED TO BE SORTED BY THE KEY VARIABLE */

PROC SORT DATA = A; BY A; RUN;
PROC SORT DATA = B; BY A; RUN;


data d;
merge a b;
by a;
run;


DATA D;
* IF A VARIABLE IS PRESENT IN [MORE THAN ] TWO DATASETS, THEN THE SAS WOULD OVERWRITE THE 
THAT VARIABLE IN THE LEFT DATASET BY THE SAME NAMED COLUMN IN THE RIGHT DATASET ; 
*MERGE A(IN = P) B(RENAME = (C = C_FROM_B) IN = Q);
MERGE B(IN = P) A (IN = Q);
BY A;
IF P OR Q; /* FULL JOIN */
*IF P AND Q; /* INNER JOIN */
*IF P ; /* LEFT JOIN */
*IF Q; /* RIGHT JOIN */

IF P AND Q THEN SOURCE = ' AB';
ELSE IF P THEN SOURCE = 'A    ';
ELSE IF Q THEN SOURCE = 'B   ';

RUN;

* ASSIGNMENT;
* USE "Jan2021_Data_Reference" TAB FROM "Loan_default_for_SAS_Training.XLSX" FILE
FOR IMPUTING MISSING OBSERVATIONS OF EDUCATION AND APPLICANTINCOME IN THE "LOAN_DF" DATASET
ALGORITHM AS FOLLOWS:
1. IMPORT THE "Jan2021_Data_Reference" TAB FROM "Loan_default_for_SAS_Training.XLSX" 
FILE AS "LOAN_DF_REF"
2. RENAME THE EDUCATION AND APPLICANTINCOME IN THE DATASET "LOAN_DF_REF" WITH "REF" AS SUFFIX
3. SORT THE DATASETS LOAN_DF AND LOAN_DF_REF BY LOAN_ID
4. MERGE THE DATASETS LOAN_DF AND LOAN_DF_REF BY LOAN_ID
5. IMPUTE THE VALUES OF EDUCATION AND APPLICANTINCOME IN THE DATASET 'LOAN_DF' 
USING THE VALUES OF EDUCATION_REF AND APPLICANTINCOME_REF IN THE DATASET 'LOAN_DF_REF' 


;


/* 1. DATA IMPORT */
/* Load XLSX file using Import Procedure */
PROC IMPORT 
DATAFILE="/home/u845941/data/Loan_default_for_SAS_Training.xlsx"
OUT=LOAN_DF_REF 
DBMS=XLSX REPLACE;
 
  SHEET="Jan2021_Data_Reference";
  GETNAMES=YES; 
  DATAROW=2;
  /* RANGE="range-name"; */
RUN;
 

* https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/proc/n1hmips60w5w3yn1hj9klna7aplw.htm;

* The DATASETS procedure is a utility procedure that manages your SAS files. 
With PROC DATASETS, you can do the following:

copy SAS files from one SAS library to another
rename SAS files
repair SAS files
delete SAS files
list the SAS files that are contained in a SAS library
list the attributes of a SAS data set:
the date on which the data was last modified
whether the data is compressed
whether the data is indexed
manipulate passwords on SAS files
append SAS data sets
modify attributes of SAS data sets and variables within the data sets
create and delete indexes on SAS data sets
create and manage audit files for SAS data sets
create and delete integrity constraints on SAS data sets
create and manage extended attributes of data sets
;
* RENAMING THE VARIABLES ;
PROC DATASETS LIB = WORK;
MODIFY LOAN_DF_REF;
RENAME EDUCATION = EDUCATION_REF APPLICANTINCOME = APPLICANTINCOME_REF;
RUN; 



PROC SORT DATA = LOAN_DF NODUPKEY; BY LOAN_ID; RUN;

PROC SORT DATA = LOAN_DF_REF (KEEP = LOAN_ID EDUCATION_REF APPLICANTINCOME_REF) NODUPKEY; 
BY LOAN_ID; RUN;

DATA LOAN_DF_IMPUT;
MERGE LOAN_DF (IN = A) LOAN_DF_REF(IN = B);
BY LOAN_ID;

IF A; *LEFT JOIN;

IF EDUCATION = '' AND EDUCATION_REF NE '' THEN EDUCATION = EDUCATION_REF;

IF APPLICANTINCOME = . AND APPLICANTINCOME_REF NE . THEN APPLICANTINCOME = APPLICANTINCOME_REF;

RUN;

data a;
input a b;
cards;
1 2
2 3
2 4
2 4
3 5
3 7
;
run;

proc sort data = a out = b nodupkey ; by a;  run;
proc sort data = a out = c nodup ; by a;  run;
title 'overall dataset ';
proc print data = a; 
title1 'nodupkey dataset';
proc print data = b;
title2 'nodup dataset';
proc print data = c; 


/* SQL */
* CAPTURING OVERALL SUM WITHOUT USING GROUP BY STATEMENT ;
PROC SQL;
CREATE TABLE CONTRI AS SELECT LOAN_ID, LOANAMOUNT, SUM(LOANAMOUNT) AS TOTAL_LOAN_AMOUNT
FROM LOAN_DF ORDER BY LOANAMOUNT DESC;
QUIT;

* CAPTURE THE TOTAL LOAN AMOUNT OF ALL APPLICANTS AS A MACRO VARIABLE TO USE IT IN SUBSEQUENT STEPS;
PROC SQL;
SELECT SUM(LOANAMOUNT) INTO: TOTAL_OUTSTANDING_AMOUNT FROM LOAN_DF;
QUIT;
&TOTAL_OUTSTANDING_AMOUNT;

/* SQL */

PROC SQL;
CREATE TABLE CONTRI_MACRO AS SELECT LOAN_ID, LOANAMOUNT, 
&TOTAL_OUTSTANDING_AMOUNT AS TOTAL_OUTSTANDING_AMOUNT
FROM LOAN_DF ORDER BY LOANAMOUNT DESC;
QUIT;


* ASSIGNMENT using sql;
* USE "Jan2021_Data_Reference" TAB FROM "Loan_default_for_SAS_Training.XLSX" FILE
FOR IMPUTING MISSING OBSERVATIONS OF EDUCATION AND APPLICANTINCOME IN THE "LOAN_DF" DATASET
ALGORITHM AS FOLLOWS:
1. IMPORT THE "Jan2021_Data_Reference" TAB FROM "Loan_default_for_SAS_Training.XLSX" 
FILE AS "LOAN_DF_SQL"
2. MERGE THE DATASETS LOAN_DF AND LOAN_DF_REF BY LOAN_ID using SQL
3. RENAME THE EDUCATION AND APPLICANTINCOME IN THE DATASET "LOAN_DF_SqL" WITH "SqL" AS SUFFIX
4. USE CASE STATEMENT : IMPUTE THE VALUES OF EDUCATION AND APPLICANTINCOME IN THE DATASET 'LOAN_DF' 
USING THE VALUES OF EDUCATION_SQL AND APPLICANTINCOME_SQL IN THE DATASET 'LOAN_DF_SQL' 

;

/* 1. DATA IMPORT */
/* Load XLSX file using Import Procedure */
PROC IMPORT 
DATAFILE="/home/u845941/data/Loan_default_for_SAS_Training.xlsx"
OUT=LOAN_DF_sql 
DBMS=XLSX REPLACE;
 
  SHEET="Jan2021_Data_Reference";
  GETNAMES=YES; 
  DATAROW=2;
  /* RANGE="range-name"; */
RUN;


PROC SQL;
CREATE TABLE LOAN_DF_SQL_IMPUTE AS SELECT
A.LOAN_ID, 
(CASE WHEN A.LOAN_ID = B.LOAN_ID AND A.EDUCATION = '' AND 
B.EDUCATION NE '' THEN B.EDUCATION ELSE A.EDUCATION END) AS EDUCATION,
(CASE WHEN A.LOAN_ID = B.LOAN_ID AND A.APPLICANTINCOME = . AND 
B.APPLICANTINCOME NE . THEN B.APPLICANTINCOME ELSE A.APPLICANTINCOME END) AS APPLICANTINCOME

FROM LOAN_DF A LEFT JOIN LOAN_DF_SQL B
ON A.LOAN_ID = B.LOAN_ID;
QUIT;


* DATA AGGREGATION ;

* compute min, max, average, median and stad deviation of applicant income, co applicant income
LoanAmount,	Loan_Amount_Term;

PROC SQL;
TITLE "DETAILS OF APPLICANT INCOME";
SELECT MIN(APPLICANTINCOME) AS MIN, MAX(APPLICANTINCOME) AS MAX,
MEAN(APPLICANTINCOME) AS AVG, MEDIAN(APPLICANTINCOME) AS MEDIAN,
STD(APPLICANTINCOME) AS STD
FROM LOAN_DF;
TITLE "DETAILS OF CO-APPLICANT INCOME";
SELECT MIN(COAPPLICANTINCOME) AS MIN, MAX(COAPPLICANTINCOME) AS MAX,
MEAN(COAPPLICANTINCOME) AS AVG, MEDIAN(COAPPLICANTINCOME) AS MEDIAN,
STD(COAPPLICANTINCOME) AS STD
FROM LOAN_DF;
QUIT;


* write a macro (user defined function) to print the summary details of one 
numeric variable;
%MACRO SQL_AGGR(INPUT_DATA,VARIABLE_NAME);
* %macro is to initiate a macro ...followed by macro name 'sql_aggr' with any number of arguments;
PROC SQL;
TITLE "&VARIABLE_NAME";
SELECT MIN(&VARIABLE_NAME) AS MIN, MAX(&VARIABLE_NAME) AS MAX,
MEAN(&VARIABLE_NAME) AS AVG, MEDIAN(&VARIABLE_NAME) AS MEDIAN,
STD(&VARIABLE_NAME) AS STD
FROM &INPUT_DATA;
%MEND;
* %mend to end the macro ; 

%SQL_AGGR(LOAN_DF,APPLICANTINCOME);
%SQL_AGGR(LOAN_DF,COAPPLICANTINCOME);
%SQL_AGGR(LOAN_DF,LoanAmount);
%SQL_AGGR(LOAN_DF,Loan_Amount_Term);



*assignment;
*
compute the loan_status_rate (average loan status) by Gender, Education, married;

;

PROC SQL;
CREATE TABLE G AS SELECT GENDER, COUNT(*) AS NUM_OBSERVATIONS, 
MEAN(CASE WHEN LOAN_STATUS = 'Y' THEN 1 ELSE 0 END) AS LOAN_STATUS_RATE
FROM LOAN_DF
GROUP BY GENDER;
QUIT;

proc print; run;
*when dataset is not specified then the last dataset will be considered 
in the print procedure ;


PROC SQL;
CREATE TABLE E AS SELECT Education, COUNT(*) AS NUM_OBSERVATIONS, 
MEAN(CASE WHEN LOAN_STATUS = 'Y' THEN 1 ELSE 0 END) AS LOAN_STATUS_RATE format=percent8.3
FROM LOAN_DF
GROUP BY Education;
QUIT;

PROC SQL;
CREATE TABLE M AS SELECT married, COUNT(*) AS NUM_OBSERVATIONS, 
MEAN(CASE WHEN LOAN_STATUS = 'Y' THEN 1 ELSE 0 END) AS LOAN_STATUS_RATE format=percent8.3
FROM LOAN_DF
GROUP BY 1;
QUIT;

* stack up all (G, E, M) the datasets one below the other;
DATA ALL;
RETAIN VARIABLE NUM_OBSERVATIONS LOAN_STATUS_RATE;
SET 
G (IN = PQR) 
E (IN = ANL)
M(IN = MEC);
FORMAT VARIABLE $12.;
IF PQR THEN VARIABLE = "GENDER";
IF ANL THEN VARIABLE = "EDUCATION";
IF MEC THEN VARIABLE = "MARRIED";
RUN;

* ABOVE CODE IS NOT HELPING AS THE VALUE OF GENDER, EDUCATION AND MARRIED IN DIFFERENT COLUMNS
HENCE RENAMING THEM ;


* stack up all (G, E, M) the datasets one below the other;
DATA ALL;
RETAIN VARIABLE VALUES NUM_OBSERVATIONS LOAN_STATUS_RATE;
FORMAT VALUES $15.;
SET 
G (IN = PQR RENAME = (GENDER = VALUES)) 
E (IN = ANL RENAME = (EDUCATION = VALUES))
M(IN = MEC RENAME = (MARRIED = VALUES));
FORMAT VARIABLE $12.;
IF PQR THEN VARIABLE = "GENDER";
IF ANL THEN VARIABLE = "EDUCATION";
IF MEC THEN VARIABLE = "MARRIED";
RUN;


* IS THERE A WAY THE ABOVE CAN BE ACHIEVED USING SQL PROCEDURE IN MINIMAL STEPS?
LET'S TRY;


PROC SQL;
CREATE TABLE ALL_SQL AS
 
SELECT 
'GENDER' AS VARIABLE FORMAT=$15., 
GENDER AS VALUES FORMAT=$15., 
COUNT(*) AS NUM_OBSERVATIONS, 
MEAN(CASE WHEN LOAN_STATUS = 'Y' THEN 1 ELSE 0 END) AS LOAN_STATUS_RATE
FROM LOAN_DF
/*GROUP BY VARIABLE,VALUES*/
GROUP BY 1,2

UNION

SELECT 'Education' AS VARIABLE FORMAT=$15.,Education AS VALUES FORMAT=$15., 
COUNT(*) AS NUM_OBSERVATIONS, 
MEAN(CASE WHEN LOAN_STATUS = 'Y' THEN 1 ELSE 0 END) AS LOAN_STATUS_RATE format=percent8.3
FROM LOAN_DF
GROUP BY 1,2

UNION

SELECT 'MARRIED' AS VARIABLE FORMAT=$15., married AS VALUES FORMAT=$15., 
COUNT(*) AS NUM_OBSERVATIONS, 
MEAN(CASE WHEN LOAN_STATUS = 'Y' THEN 1 ELSE 0 END) AS LOAN_STATUS_RATE format=percent8.3
FROM LOAN_DF
GROUP BY 1,2;
QUIT;






	
*17	Convert LOAN_STATUS" variable in to Numeric with Yes takes a value of 1 and No 0;
DATA LOAN_DF_NUMERIC;
SET LOAN_DF;
IF LOAN_STATUS = 'Y' THEN LOAN_STATUS = 1;
IF LOAN_STATUS = 'N' THEN LOAN_STATUS = 0;
LOAN_S = INPUT(LOAN_STATUS, BEST5.);
DROP LOAN_STATUS;
RENAME LOAN_S=Loan_Status;
RUN; 
PROC CONTENTS DATA = LOAN_DF_NUMERIC; RUN;

*18	Convert Location variable in to Ordinal variable with Urban takes value of 3, Semi Urban 2 and Rural 1;




*19	Impute Loan Amount missings by average of Loan Amount based on Gender;
/* method 1*/
PROC MEANS DATA = LOAN_DF N MEAN;
CLASS GENDER;
VAR LOANAMOUNT;
RUN;

DATA DF_LOAN_IMPU;
SET LOAN_DF;
LOANAMOUNT_NEW = LOANAMOUNT;
IF GENDER = 'Male' AND LOANAMOUNT_NEW = . THEN LOANAMOUNT_NEW = 149.91919191;
IF GENDER = 'Female' AND LOANAMOUNT_NEW = . THEN LOANAMOUNT_NEW = 129.91919191;
 

RUN;


/* method 2*/
PROC SQL;
CREATE TABLE AVG_LOAN_AMT_GENDER AS SELECT
GENDER, AVG(LOANAMOUNT) AS AVG_LOAN_AMT FROM LOAN_DF /* WHERE GENDER NE '' */
GROUP BY 1;
QUIT;

PROC SQL;
CREATE TABLE LOAN_DF_LOAN_IMPU AS SELECT
 CASE WHEN LOANAMOUNT = . THEN AVG_LOAN_AMT ELSE LOANAMOUNT END AS NEW_LOAN_AMOUNT
 , a.*
FROM LOAN_DF A LEFT JOIN AVG_LOAN_AMT_GENDER B
ON A.GENDER = B.GENDER;
QUIT;


PROC SORT DATA = LOAN_DF;
BY GENDER;
RUN;

DATA LOAN_DF_MERGE_IMPUTE;
MERGE LOAN_DF(IN = A) AVG_LOAN_AMT_GENDER (IN = B);
BY GENDER;

IF A; /* Left Join */
/* if B */ /* Right Join */
/* if a or B / /* full Join */
/* if a and B */ /* inner Join */



IF LOANAMOUNT = . THEN NEW_LOAN_AMOUNT = AVG_LOAN_AMT; ELSE NEW_LOAN_AMOUNT = LOANAMOUNT;

RUN;


************************************************************************;
/* Sample SAS code for dynamic exchange of information from SAS to excel 
using X4ML Macro Language */

/* Here a dataset city_info with three variables name,age and city is created */
Data city_info;
input name $10. age 2. city $7.; 
cards;
Ramesh 	  23 BNG
Ashish 	  45 DEL
Srikanth  47 DEL
Ram 	  56 BNG
Vinay 	  77 KGP
Neeraj 	  23 DEL
Harish 	  56 KGP
Rajesh 	  43 BNG
John 	  21 BNG
James 	  46 KGP
;
run;
/* These are system options, for asynchronous mode of operation*/
options noxwait noxsync;

filename sas2xl dde 'excel|system';
data _null_;
file sas2xl;
put '[open("/home/u845941/data/test1.xls")]';
run;

/* DDE stands for dynamic data exchange, very frequently used for
digitization purposes. The dde operator, opens the appropriate excel 
sheet, "info_sheet" in our case and dumps the data. "info" is the 
reference to the file name. The '09'x what you see
below are the hexadecimal values for the tab operator.*/

filename info dde "excel|[test1.xls]sheet2!r1c1:r11c3";
data  _null_;
         FILE info notab lrecl=32653;
		 set city_info;
		  if _n_=1 then do;
   put 'Name ' '09'x 'Age ' '09'x 'City ';
   end;
   put  Name '09'x Age '09'x City;
run;

filename cmds dde 'excel|system';
/* The following piece of code, selects the appropriate cells and formats it.
There are various options, all you can think of like "italics","underline","bold",
etc.*/
data _null_;
   file cmds;

   /* the worksheet named "info_sheet" is activated*/
   put '[workbook.activate("test1")]';
   /* Cells r1c1:r1c3 are selected and formatted*/
   put '[select("r1c1:r1c3")]';
   put '[format.font("Georgia",14,true,false,false,false,0,false,true)]';
   /* Cells r2c1:r11c3 are selected and formatted in a different way */
   put '[select("r2c1:r11c3")]';
   put '[format.font("Tahoma",12,false,false,false,false,0,false,false)]';
   put '[patterns(1,0,40)]';
   /* column justifications */
   put '[column.width(0,"c1:c3",false,3)]';
   /* Save the excel file and quit it */
   put '[SAVE()]';
   put '[QUIT()]';
run;


*********************************************;


*20	How do you impute missing values of  "Dependents" and "Education";
	
*21	Compute Log of Applicant Income, Square Root of Applicant Income and Inverse of Applicant Income;
*22	Compute Family Income as sum of ApplicantIncome and CoApplicantIncome;

	
*28	Compute the average, standard deviation and range of the following variables along with the number of observations for each group
	ApplicantIncome
	CoApplicantIncome
	Loan Amount
	Loan Term
	for the above Group by using the following dimensions
	Gender
	Gender, Education
	Gender, Dependents, Education
	Apply the following conditions
	Credit History = 1;
	
*29	Plot the association between ApplicantIncome and Loan Amount;
 
proc gplot data = LOAN_DF;
plot ApplicantIncome*LoanAmount ; 
run;
 
 
*30	Plot the association between Education and Loan Status;

proc gplot data = LOAN_DF;
plot Education*Loan_Status ; 
run;

*31	create a bubble chart with Education (X) and Loan Status (Y) and Loan Amount as the size of the bubble; 
*Please label the all axes appropriately; 
*keep Loan Amount units in '000s;
ods listing style=htmlblue;
ods graphics / width=5in height=2.81in;

title 'LoanAmount by Education and Loan Status';
proc sgplot data=LOAN_DF noautolegend;
  bubble x=Education y=Loan_Status size=LoanAmount / 
    transparency=0.4 datalabelattrs=(size=9 weight=bold);
  inset "Bubble size represents Loan Amount" / position=bottomright textattrs=(size=11);
  yaxis grid;
  xaxis grid;
run;

 







/* FEATURE ENGINEERING / DATA MANIPULATIONS Using Various Functions */







/* DATA AGGREGATION */





/* DATA JOINS DATA IMPUTATIONS DATA EXPORT */





/* DATA VISUALIZATION */

/* DATA EXPLORATION */


/* DATA ACCESS */
