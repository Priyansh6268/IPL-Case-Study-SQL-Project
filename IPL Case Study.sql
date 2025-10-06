create database ipl;

use ipl;

-- Q1 WHAT ARE THE TOP 5 PLAYERS WITH THE MOST PLAYER OF THE MATCH AWARDS?

select player_of_match,count(*) as awards_count
from matches group by player_of_match
order by awards_count desc 
limit 5;

-- Q2 HOW MANY MATCHES WERE WON BY EACH TEAM IN EACH SEASON?

select season,winner as team,count(*) as matches_won
from matches group by season,winner;

-- Q3 WHAT IS THE AVERAGE STRIKE RATE OF BATSMEN IN THE IPL DATASET?

WITH batsman_stats AS (
    SELECT 
        batsman, 
        (SUM(total_runs) / COUNT(ball)) * 100 AS strike_rate
    FROM deliveries
    GROUP BY batsman
)
SELECT AVG(strike_rate) AS average_strike_rate
FROM batsman_stats;


-- Q4 WHAT IS THE NUMBER OF MATCHES WON BY EACH TEAM BATTING FIRST VERSUS BATTING SECOND?

WITH batting_first_teams AS (
    SELECT 
        CASE 
            WHEN win_by_runs > 0 THEN team1
            ELSE team2
        END AS batting_first
    FROM matches
    WHERE winner != 'Tie'
)
SELECT 
    batting_first,
    COUNT(*) AS matches_won
FROM batting_first_teams
GROUP BY batting_first;

-- Q5 WHICH BATSMAN HAS THE HIGHEST STRIKE RATE (MINIMUM 200 RUNS SCORED)?

select batsman,(sum(batsman_runs)*100/count(*))
as strike_rate
from deliveries group by batsman
having sum(batsman_runs)>=200
order by strike_rate desc
limit 1;

-- Q6 HOW MANY TIMES HAS EACH BATSMAN BEEN DISMISSED BY THE BOWLER 'MALINGA'?

select batsman,count(*) as total_dismissals
from deliveries 
where player_dismissed is not null 
and bowler='SL Malinga'
group by batsman;

-- Q7 WHAT IS THE AVERAGE PERCENTAGE OF BOUNDARIES (FOURS AND SIXES COMBINED) HIT BY EACH BATSMAN?

select batsman,avg(case when batsman_runs=4 or batsman_runs=6
then 1 else 0 end)*100 as average_boundaries
from deliveries group by batsman;

-- Q8 WHAT IS THE AVERAGE NUMBER OF BOUNDARIES HIT BY EACH TEAM IN EACH SEASON?

WITH team_boundaries AS (
    SELECT 
        season,
        match_id,
        batting_team,
        SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) AS fours,
        SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) AS sixes
    FROM deliveries
    JOIN matches ON deliveries.match_id = matches.id
    GROUP BY season, match_id, batting_team
)
SELECT 
    season,
    batting_team,
    AVG(fours + sixes) AS average_boundaries
FROM team_boundaries
GROUP BY season, batting_team;

-- Q9 WHAT IS THE HIGHEST PARTNERSHIP (RUNS) FOR EACH TEAM IN EACH SEASON?

WITH team_scores AS (
    SELECT 
        season,
        match_id,
        batting_team,
        over_no,
        SUM(batsman_runs) AS partnership,
        SUM(batsman_runs) + SUM(extra_runs) AS total_runs
    FROM deliveries
    JOIN matches ON deliveries.match_id = matches.id
    GROUP BY season, match_id, batting_team, over_no
),
team_partnerships AS (
    SELECT 
        season,
        batting_team,
        partnership,
        SUM(total_runs) AS total_runs
    FROM team_scores
    GROUP BY season, batting_team, partnership
)
SELECT 
    season,
    batting_team,
    MAX(total_runs) AS highest_partnership
FROM team_partnerships
GROUP BY season, batting_team;


-- Q10 HOW MANY EXTRAS (WIDES & NO-BALLS) WERE BOWLED BY EACH TEAM IN EACH MATCH?

select m.id as match_no,d.bowling_team,
sum(d.extra_runs) as extras
from matches as m
join deliveries as d on d.match_id=m.id
where extra_runs>0
group by m.id,d.bowling_team;

-- Q11 WHICH BOWLER HAS THE BEST BOWLING FIGURES (MOST WICKETS TAKEN) IN A SINGLE MATCH?

select m.id as match_no,d.bowler,count(*) as wickets_taken
from matches as m
join deliveries as d on d.match_id=m.id
where d.player_dismissed is not null
group by m.id,d.bowler
order by wickets_taken desc
limit 1;

-- Q12 HOW MANY MATCHES RESULTED IN A WIN FOR EACH TEAM IN EACH CITY?

select m.city,case when m.team1=m.winner then m.team1
when m.team2=m.winner then m.team2
else 'draw'
end as winning_team,
count(*) as wins
from matches as m
join deliveries as d on d.match_id=m.id
where m.result!='Tie'
group by m.city,winning_team;

-- Q13 HOW MANY TIMES DID EACH TEAM WIN THE TOSS IN EACH SEASON?

select season,toss_winner,count(*) as toss_wins
from matches group by season,toss_winner;

-- Q14 HOW MANY MATCHES DID EACH PLAYER WIN THE "PLAYER OF THE MATCH" AWARD?

select player_of_match,count(*) as total_wins
from matches 
where player_of_match is not null
group by player_of_match
order by total_wins desc;

-- Q15 WHAT IS THE AVERAGE NUMBER OF RUNS SCORED IN EACH OVER OF THE INNINGS IN EACH MATCH?

select m.id,d.inning,d.over_no,
avg(d.total_runs) as average_runs_per_over
from matches as m
join deliveries as d on d.match_id=m.id
group by m.id,d.inning,d.over_no;

-- Q16 WHICH TEAM HAS THE HIGHEST TOTAL SCORE IN A SINGLE MATCH?

select m.season,m.id as match_no,d.batting_team,
sum(d.total_runs) as total_score
from matches as m
join deliveries as d on d.match_id=m.id
group by m.season,m.id,d.batting_team
order by total_score desc
limit 1;

-- Q17 WHICH BATSMAN HAS SCORED THE MOST RUNS IN A SINGLE MATCH?

select m.season,m.id as match_no,d.batsman,
sum(d.batsman_runs) as total_runs
from matches as m
join deliveries as d on d.match_id=m.id
group by m.season,m.id,d.batsman
order by total_runs desc
limit 1;
