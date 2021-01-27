#
# ECE356 - Lab 4
# Fall 2020
# This script will create 1 table for each classification task (this can be exported to csv after)
# Task A's table: SelectedFeaturesA
# Task B's table: SelectedFeaturesB

#
# Create awards table
DROP TABLE IF EXISTS count_awards;

Create table count_awards as
SELECT
	playerID,
	sum(awardID='ALCS MVP') As ALCS_MVP,
    #(Select SUM(awardID='Most Valuable Player') where lgID = 'AL') as AL_MVP,
    sum(awardID='NLCS MVP') As NLCS_MVP,
	#(Select SUM(awardID='Most Valuable Player') where lgID = 'NL') as NL_MVP,
	sum(awardID='All-Star Game MVP') As AllStar_MVP,
	sum(awardID='Cy Young Award') As Cy_Young_Award,
    sum(awardID='Gold Glove') As Gold_Glove_Award,
    sum(awardID='Silver Slugger') As Silver_Slugger,
    sum(awardID='World Series MVP') As World_Series_MVP
FROM AwardsPlayers
GROUP BY
  playerID;

ALTER TABLE count_awards
ADD PRIMARY KEY (playerID),
ADD column AL_MVP decimal(23,0),
ADD column NL_MVP decimal(23,0),
ADD column MVP decimal(23,0);

DROP TABLE IF EXISTS AL;
CREATE TABLE AL as
Select playerID, SUM(awardID='Most Valuable Player') as AL_MVP from AwardsPlayers where lgID = 'AL' group by playerID;

UPDATE count_awards ca INNER JOIN AL ON ca.playerID = AL.playerID 
set ca.AL_MVP = AL.AL_MVP;

DROP TABLE IF EXISTS NL;
CREATE TABLE NL as
Select playerID, SUM(awardID='Most Valuable Player') as NL_MVP from AwardsPlayers where lgID = 'NL' group by playerID;

UPDATE count_awards ca INNER JOIN NL ON ca.playerID = NL.playerID 
set ca.NL_MVP = NL.NL_MVP;

# update columns that have null values with 0
UPDATE count_awards SET AL_MVP = 0 where AL_MVP is null;
UPDATE count_awards SET NL_MVP = 0 where NL_MVP is null;

# Combine the count of different MVP awards
UPDATE count_awards SET 
MVP = ALCS_MVP + AL_MVP + NLCS_MVP + NL_MVP + World_Series_MVP + AllStar_MVP;

# Drop unnecessary columns
ALTER TABLE count_awards 
DROP column ALCS_MVP, 
DROP column NLCS_MVP,
DROP column AL_MVP,
DROP column NL_MVP,
DROP column World_Series_MVP, 
DROP column AllStar_MVP;

#END CREATE AWARDS TABLE
#

#
# CREATE other tables
DROP TABLE IF EXISTS `BattingF`;
CREATE TABLE `BattingF` (
  `playerID` varchar(255),
  `BatG` int(11) DEFAULT 0,
  `BatBA` FLOAT(4) DEFAULT 0,
  `BatHR` FLOAT(11) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `FieldingF`;
CREATE TABLE `FieldingF` (
  `playerID` varchar(255),
  `FieldG` int(11) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `PitchingF`;
CREATE TABLE `PitchingF` (
  `playerID` varchar(255),
  `PitchW` int(11) DEFAULT 0,
  `PitchL` int(11) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `AllstarFullF`;
CREATE TABLE `AllstarFullF` (
  `playerID` varchar(255),
  `allStarCount` int(11) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `MasterF`;
CREATE TABLE `MasterF` (
  `playerID` varchar(255),
  `daysActive` int DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SalariesF`;
CREATE TABLE `SalariesF` (
  `playerID` varchar(255),
  `avgSalary` int(11) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `HallOfFameFA`;
CREATE TABLE `HallOfFameFA` (
  `playerID` varchar(255),
  `inducted` bool DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `HallOfFameFB`;
CREATE TABLE `HallOfFameFB` (
  `playerID` varchar(255),
  `inducted` bool DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# INSERT INTO New tables. This is the feature selection.

# Select from Batting and BattingPost
INSERT INTO BattingF
SELECT t.playerID, SUM(t.G),  IF(SUM(t.AB)>0, (SUM(t.H)/SUM(t.AB)), 0), SUM(t.HR)
    FROM (SELECT playerID, G, H, AB, HR FROM Batting
          UNION ALL
          SELECT  playerID, G, H, AB, HR FROM BattingPost) t
      Group by t.playerID;

INSERT INTO FieldingF
SELECT t.playerID, SUM(t.G)
    FROM (SELECT playerID, G FROM Fielding
          UNION ALL
          SELECT  playerID, G FROM FieldingPost) t
      Group by t.playerID;

INSERT INTO PitchingF 
SELECT t.playerID, SUM(t.W), SUM(t.L)
    FROM (SELECT playerID, W, L FROM Pitching
          UNION ALL
          SELECT  playerID, W, L FROM PitchingPost) t
      Group by t.playerID;
 
# Count of allstar games for player
INSERT INTO AllstarFullF
SELECT playerID, COUNT(*)
FROM AllstarFull 
GROUP BY playerID;

# Count the days  active and remove any players that have 0 days active
INSERT INTO MasterF
SELECT playerID, TIMESTAMPDIFF(DAY, STR_TO_DATE(COALESCE(NULLIF(debut,''),'1970-01-01'), '%Y-%m-%d'), STR_TO_DATE(COALESCE(NULLIF(finalGame,''), '1970-01-01'), '%Y-%m-%d')) as daysActive
FROM Master
where TIMESTAMPDIFF(DAY, STR_TO_DATE(COALESCE(NULLIF(debut,''),'1970-01-01'), '%Y-%m-%d'), STR_TO_DATE(COALESCE(NULLIF(finalGame,''), '1970-01-01'), '%Y-%m-%d')) != 0;

# Calculate the avg salary
INSERT INTO SalariesF
SELECT playerID, AVG(salary)
FROM Salaries
GROUP BY playerID;

# Out of all nominations into the hall of fame did they get inducted? (boolean)

# Task A (Want all inducted rows to be 1)
INSERT INTO HallOfFameFA
SELECT t1.playerID, MAX(inductedInt)
FROM (
	SELECT playerID, IF (inducted = 'Y', 1, 1) as inductedInt
	FROM HallOfFame hof) t1
GROUP BY t1.playerID;

# Task B
INSERT INTO HallOfFameFB
SELECT t1.playerID, SUM(inductedInt)
FROM (
	SELECT playerID, IF (inducted = 'Y', 1, 0) as inductedInt
	FROM HallOfFame hof) t1
GROUP BY t1.playerID;

# Create final Feature Selection tables. This table can be converted to a csv with the following command
# mysql -B -h manta.uwaterloo.ca -u user_$USER -p ece356db_$USER -e "select * from FeatureSelection" | sed 's/\t/,/g' > output.csv
DROP TABLE IF EXISTS `SelectedFeaturesA`;
CREATE TABLE `SelectedFeaturesA`
SELECT m.playerID, daysActive, BatG, BatBA, BatHR, FieldG, PitchW, PitchL, allStarCount, Cy_Young_Award, Gold_Glove_Award, Silver_Slugger, MVP, avgSalary, inducted
FROM MasterF m 
LEFT OUTER JOIN BattingF bf ON m.playerID = bf.playerID
LEFT OUTER JOIN FieldingF ff ON m.playerID = ff.playerID
LEFT OUTER JOIN PitchingF pf ON m.playerID = pf.playerID
LEFT OUTER JOIN AllstarFullF af ON m.playerID = af.playerID
LEFT OUTER JOIN count_awards ca on m.playerID = ca.playerID
LEFT OUTER JOIN SalariesF sf on m.playerID = sf.playerID
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID; 




DROP TABLE IF EXISTS `SelectedFeaturesB`;
CREATE TABLE `SelectedFeaturesB`
SELECT m.playerID, daysActive, BatG, BatBA, BatHR, FieldG, PitchW, PitchL, allStarCount, Cy_Young_Award, Gold_Glove_Award, Silver_Slugger, MVP, avgSalary, inducted
FROM MasterF m 
LEFT OUTER JOIN BattingF bf ON m.playerID = bf.playerID
LEFT OUTER JOIN FieldingF ff ON m.playerID = ff.playerID
LEFT OUTER JOIN PitchingF pf ON m.playerID = pf.playerID
LEFT OUTER JOIN AllstarFullF af ON m.playerID = af.playerID
LEFT OUTER JOIN count_awards ca on m.playerID = ca.playerID
LEFT OUTER JOIN SalariesF sf on m.playerID = sf.playerID
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID; 


# Update null values to 0 for both tables
UPDATE SelectedFeaturesA
SET daysActive = COALESCE(daysActive, 0),
BatG = COALESCE(BatG, 0),
BatBA = COALESCE(BatBA, 0),
BatHR = COALESCE(BatHR, 0),
FieldG = COALESCE(FieldG, 0),
PitchW = COALESCE(PitchW, 0),
PitchL = COALESCE(PitchL, 0),
allStarCount = COALESCE(allStarCount, 0),
Cy_Young_Award = COALESCE(Cy_Young_Award, 0),
Gold_Glove_Award = COALESCE(Gold_Glove_Award, 0),
Silver_Slugger = COALESCE(Silver_Slugger, 0),
MVP = COALESCE(MVP, 0),
avgSalary = COALESCE(avgSalary, 0),
inducted = COALESCE(inducted, 0);

UPDATE SelectedFeaturesB
SET daysActive = COALESCE(daysActive, 0),
BatG = COALESCE(BatG, 0),
BatBA = COALESCE(BatBA, 0),
BatHR = COALESCE(BatHR, 0),
FieldG = COALESCE(FieldG, 0),
PitchW = COALESCE(PitchW, 0),
PitchL = COALESCE(PitchL, 0),
allStarCount = COALESCE(allStarCount, 0),
Cy_Young_Award = COALESCE(Cy_Young_Award, 0),
Gold_Glove_Award = COALESCE(Gold_Glove_Award, 0),
Silver_Slugger = COALESCE(Silver_Slugger, 0),
MVP = COALESCE(MVP, 0),
avgSalary = COALESCE(avgSalary, 0),
inducted = COALESCE(inducted, 0);