--Avg nr of siblings for each ethnic group
select EthnicGroup, avg(NrSiblings) as avg_nr_sblng
from examscore
group by EthnicGroup

--Checking the average scores, according to degree and ethnic group
select parenteduc, ethnicgroup, 
ROW_NUMBER() over(partition by parenteduc order by ethnicgroup) group_row_nr,
round(avg(mathscore),0) avg_math,
round(avg(readingscore),0) avg_read,
round(avg(writingscore),0) avg_write
from examscore where parenteduc is not null
group by parenteduc, ethnicgroup

--Number of students who got above average math score according to their lunchtype
select lunchtype, count(*) as above_avg_math
from examscore where mathscore > (select AVG(mathscore) from examscore)
group by LunchType
--Checking whether effort level is effective in different exam scores
select	wklystudyhours,
		round(avg(mathscore),0) as avg_math,
		round(avg(readingscore),0) as avg_reading,
		round(avg(writingscore),0) as avg_writing,
case
when wklystudyhours = '< 5' then 'low effort'
when wklystudyhours	= '5 - 10' then 'some effort'
when wklystudyhours = '> 10' then 'high effort'
end as 'effort level'
from examscore
group by wklystudyhours

--Checking which gender studies more 
select gender, wklystudyhours, count(*) as nr_of_students, 
ROW_NUMBER() over(partition by gender order by wklystudyhours) as row_nr
from examscore 
group by gender, wklystudyhours

--Creating a function which gives the number of students who got the stated math score
create function count_students(
@mathscore int
)
returns int
as
begin 
declare @nr_of_s int
select @nr_of_s = count(*) from examscore where mathscore = @mathscore
return @nr_of_s
end 

select dbo.count_students(85)


--AVERAGE MATH GRADES AND NUMBER OF STUDENTS WHO GOT ABOVE AVG GRADES FOR EACH WEEKLY STUDY HOURS
select q1.wklystudyhours, q1.avg_math_grade, q2.abv_avg_math_count from
(
select wklystudyhours, round(avg(mathscore),0) as avg_math_grade from examscore
group by wklystudyhours
) q1
join
(select wklystudyhours, count(*) as abv_avg_math_count from examscore
where mathscore > (select avg(mathscore) from examscore)
group by wklystudyhours) q2 on q1.WklyStudyHours = q2.WklyStudyHours

--Average reading grades and number of siblings
select nrsiblings, round(avg(ReadingScore),1) avg_read from examscore
where nrsiblings is not null
group by nrsiblings
order by avg_read desc 

--Are students who are first children more successful in exams?
SELECT examscore.IsFirstChild,
    COUNT(CASE WHEN examscore.MathScore = max_scores.max_math THEN 1 ELSE NULL END) AS nr_max_math_g,
    COUNT(CASE WHEN examscore.ReadingScore = max_scores.max_read THEN 1 ELSE NULL END) AS nr_max_rd_g,
    COUNT(CASE WHEN examscore.WritingScore = max_scores.max_write THEN 1 ELSE NULL END) AS nr_max_wr_g
FROM examscore 
JOIN (
    SELECT IsFirstChild,
        MAX(MathScore) AS max_math,
        MAX(ReadingScore) AS max_read,
        MAX(WritingScore) AS max_write
    FROM examscore
    WHERE IsFirstChild IS NOT NULL
    GROUP BY IsFirstChild
) AS max_scores
ON examscore.IsFirstChild = max_scores.IsFirstChild
AND (examscore.MathScore = max_scores.max_math
     OR examscore.ReadingScore = max_scores.max_read
     OR examscore.WritingScore = max_scores.max_write)
GROUP BY examscore.IsFirstChild;



