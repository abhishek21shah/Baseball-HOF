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
	sum(awardID='Babe Ruth Award') As Babe_Ruth_Award,
	sum(awardID='Cy Young Award') As Cy_Young_Award,
    sum(awardID='Gold Glove') As Gold_Glove_Award,
    sum(awardID='Outstanding DH Award') As DH_Award,
	SUM(awardID='Pitching Triple Crown') As Pitching_Crown,
    sum(awardID='Rolaids Relief Man Award') As Relief_Award,
    sum(awardID='Rookie of the Year') As ROY_Award,
    sum(awardID='Silver Slugger') As Silver_Slugger,
    sum(awardID='Triple Crown') As Batting_Crown,
    sum(awardID='World Series MVP') As World_Series_MVP
FROM AwardsPlayers
GROUP BY
  playerID;

ALTER TABLE count_awards
ADD PRIMARY KEY (playerID),
ADD column AL_MVP decimal(23,0),
ADD column NL_MVP decimal(23,0);

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

# Combine the count of all AL/NL awards
UPDATE count_awards SET 
AL_MVP = ALCS_MVP + AL_MVP,
NL_MVP = NLCS_MVP + NL_MVP;

# Drop unnecessary columns
ALTER TABLE count_awards 
DROP column ALCS_MVP, 
DROP column NLCS_MVP;

#END CREATE AWARDS TABLE
#

#
# CREATE other tables
DROP TABLE IF EXISTS `BattingF`;
CREATE TABLE `BattingF` (
  `playerID` varchar(255),
  `BatG` int(11) DEFAULT 0,
  `BatAB` int(11) DEFAULT 0,
  `BatR` int(11) DEFAULT 0,
  `BatH` int(11) DEFAULT 0,
  `Bat2B` int(11) DEFAULT 0,
  `Bat3B` int(11) DEFAULT 0,
  `BatHR` int(11) DEFAULT 0,
  `BatRBI` int(11) DEFAULT 0,
  `BatSB` int(11) DEFAULT 0,
  `BatCS` int(11) DEFAULT 0,
  `BatBB` int(11) DEFAULT 0,
  `BatSO` int(11) DEFAULT 0,
  `BatIBB` varchar(255) DEFAULT 0,
  `BatHBP` varchar(255) DEFAULT 0,
  `BatSH` varchar(255) DEFAULT 0,
  `BatSF` varchar(255) DEFAULT 0,
  `BatGIDP` varchar(255) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `FieldingF`;
CREATE TABLE `FieldingF` (
  `playerID` varchar(255),
  `FieldG` int(11) DEFAULT 0,
  `FieldGS` varchar(255) DEFAULT 0,
  `FieldInnOuts` varchar(255) DEFAULT 0,
  `FieldPO` int(11) DEFAULT 0,
  `FieldA` int(11) DEFAULT 0,
  `FieldE` int(11) DEFAULT 0,
  `FieldDP` int(11) DEFAULT 0,
  `FieldPB` varchar(255) DEFAULT 0,
  `FieldWP` varchar(255) DEFAULT 0,
  `FieldSB` varchar(255) DEFAULT 0,
  `FieldCS` varchar(255) DEFAULT 0,
  `FieldZR` varchar(255) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `PitchingF`;
CREATE TABLE `PitchingF` (
  `playerID` varchar(255),
  `PitchW` int(11) DEFAULT 0,
  `PitchL` int(11) DEFAULT 0,
  `PitchG` int(11) DEFAULT 0,
  `PitchGS` int(11) DEFAULT 0,
  `PitchCG` int(11) DEFAULT 0,
  `PitchSHO` int(11) DEFAULT 0,
  `PitchSV` int(11) DEFAULT 0,
  `PitchIPouts` int(11) DEFAULT 0,
  `PitchH` int(11) DEFAULT 0,
  `PitchER` int(11) DEFAULT 0,
  `PitchHR` int(11) DEFAULT 0,
  `PitchBB` int(11) DEFAULT 0,
  `PitchSO` int(11) DEFAULT 0,
  `PitchBAOpp` varchar(255) DEFAULT 0,
  `PitchERA` float DEFAULT 0,
  `PitchIBB` varchar(255) DEFAULT 0,
  `PitchWP` varchar(255) DEFAULT 0,
  `PitchHBP` varchar(255) DEFAULT 0,
  `PitchBK` int(11) DEFAULT 0,
  `PitchBFP` varchar(255) DEFAULT 0,
  `PitchGF` varchar(255) DEFAULT 0,
  `PitchR` int(11) DEFAULT 0,
  `PitchSH` varchar(255) DEFAULT 0,
  `PitchSF` varchar(255) DEFAULT 0,
  `PitchGIDP` varchar(255) DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `AllstarFullF`;
CREATE TABLE `AllstarFullF` (
  `playerID` varchar(255),
  `allStarCount` int(11) DEFAULT 0,
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

INSERT INTO BattingF
SELECT playerID, SUM(G), SUM(AB), SUM(R), SUM(H), SUM(2B), SUM(3B), SUM(HR), SUM(RBI), SUM(SB), SUM(CS), SUM(BB), SUM(SO), SUM(IBB), SUM(HBP), SUM(SH), SUM(SF), SUM(GIDP)
FROM Batting
GROUP BY playerID;

INSERT INTO FieldingF
SELECT playerID, SUM(G), SUM(GS), SUM(InnOuts), SUM(PO), SUM(A), SUM(E), SUM(DP), SUM(PB), SUM(WP), SUM(SB), SUM(CS), SUM(ZR)
FROM Fielding
GROUP BY playerID;

INSERT INTO PitchingF 
SELECT playerID, SUM(W), SUM(L), SUM(G), SUM(GS), SUM(CG), SUM(SHO), SUM(SV), SUM(IPouts), SUM(H), SUM(ER), SUM(HR), SUM(BB), SUM(SO), SUM(BAOpp), SUM(ERA), SUM(IBB), SUM(WP), SUM(HBP), SUM(BK), SUM(BFP), SUM(GF), SUM(R), SUM(SH), SUM(SF), SUM(GIDP)
FROM Pitching 
GROUP BY playerID;

# Count of allstar games for player
INSERT INTO AllstarFullF
SELECT playerID, COUNT(*)
FROM AllstarFull 
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
SELECT m.playerID, BatG, BatAB, BatR, BatH, Bat2B, Bat3B, BatHR, BatRBI, BatSB, BatCS, BatBB, BatSO, BatIBB, BatHBP, BatSH, BatSF, BatGIDP, FieldG, FieldGS, FieldInnOuts, FieldPO, FieldA, FieldE, FieldDP, FieldPB, FieldWP, FieldSB, FieldCS, FieldZR, PitchW, PitchL, PitchG, PitchGS, PitchCG, PitchSHO, PitchSV, PitchIPouts, PitchH, PitchER, PitchHR, PitchBB, PitchSO, PitchBAOpp, PitchERA, PitchIBB, PitchWP, PitchHBP, PitchBK, PitchBFP, PitchGF, PitchR, PitchSH, PitchSF, PitchGIDP, allStarCount, AllStar_MVP, Babe_Ruth_Award, Cy_Young_Award, Gold_Glove_Award, DH_Award, Pitching_Crown, Relief_Award, ROY_Award, Silver_Slugger, Batting_Crown, World_Series_MVP, AL_MVP, NL_MVP, inducted
FROM Master m 
LEFT OUTER JOIN BattingF bf ON m.playerID = bf.playerID
LEFT OUTER JOIN FieldingF ff ON m.playerID = ff.playerID
LEFT OUTER JOIN PitchingF pf ON m.playerID = pf.playerID
LEFT OUTER JOIN AllstarFullF af ON m.playerID = af.playerID
LEFT OUTER JOIN count_awards ca on m.playerID = ca.playerID
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID; 

DROP TABLE IF EXISTS `SelectedFeaturesB`;
CREATE TABLE `SelectedFeaturesB`
SELECT m.playerID, BatG, BatAB, BatR, BatH, Bat2B, Bat3B, BatHR, BatRBI, BatSB, BatCS, BatBB, BatSO, BatIBB, BatHBP, BatSH, BatSF, BatGIDP, FieldG, FieldGS, FieldInnOuts, FieldPO, FieldA, FieldE, FieldDP, FieldPB, FieldWP, FieldSB, FieldCS, FieldZR, PitchW, PitchL, PitchG, PitchGS, PitchCG, PitchSHO, PitchSV, PitchIPouts, PitchH, PitchER, PitchHR, PitchBB, PitchSO, PitchBAOpp, PitchERA, PitchIBB, PitchWP, PitchHBP, PitchBK, PitchBFP, PitchGF, PitchR, PitchSH, PitchSF, PitchGIDP, allStarCount, AllStar_MVP, Babe_Ruth_Award, Cy_Young_Award, Gold_Glove_Award, DH_Award, Pitching_Crown, Relief_Award, ROY_Award, Silver_Slugger, Batting_Crown, World_Series_MVP, AL_MVP, NL_MVP, inducted
FROM Master m 
LEFT OUTER JOIN BattingF bf ON m.playerID = bf.playerID
LEFT OUTER JOIN FieldingF ff ON m.playerID = ff.playerID
LEFT OUTER JOIN PitchingF pf ON m.playerID = pf.playerID
LEFT OUTER JOIN AllstarFullF af ON m.playerID = af.playerID
LEFT OUTER JOIN count_awards ca on m.playerID = ca.playerID
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID; 

# Update null values to 0 for both tables
UPDATE SelectedFeaturesA
SET BatG = COALESCE(BatG, 0),
BatAB = COALESCE(BatAB, 0),
BatR  = COALESCE(BatR, 0), 
BatH  = COALESCE(BatH, 0), 
Bat2B = COALESCE(Bat2B, 0), 
Bat3B = COALESCE(Bat3B, 0), 
BatHR = COALESCE(BatHR, 0), 
BatRBI = COALESCE(BatRBI, 0),
BatSB = COALESCE(BatSB, 0),
BatCS = COALESCE(BatCS, 0),
BatBB = COALESCE(BatBB, 0),
BatSO = COALESCE(BatSO, 0),
BatIBB = COALESCE(BatIBB, 0),
BatHBP = COALESCE(BatHBP, 0),
BatSH = COALESCE(BatSH, 0),
BatSF = COALESCE(BatSF, 0),
BatGIDP = COALESCE(BatGIDP, 0),
FieldG = COALESCE(FieldG, 0),
FieldGS = COALESCE(FieldGS, 0),
FieldInnOuts = COALESCE(FieldInnOuts, 0),
FieldPO = COALESCE(FieldPO, 0),
FieldA = COALESCE(FieldA, 0),
FieldE = COALESCE(FieldE, 0),
FieldDP = COALESCE(FieldDP, 0),
FieldPB = COALESCE(FieldPB, 0),
FieldWP = COALESCE(FieldWP, 0),
FieldSB = COALESCE(FieldSB, 0),
FieldCS = COALESCE(FieldCS, 0),
FieldZR = COALESCE(FieldZR, 0),
PitchW = COALESCE(PitchW, 0),
PitchL = COALESCE(PitchL, 0),
PitchG = COALESCE(PitchG, 0),
PitchGS = COALESCE(PitchGS, 0),
PitchCG = COALESCE(PitchCG, 0),
PitchSHO = COALESCE(PitchSHO, 0),
PitchSV = COALESCE(PitchSV, 0),
PitchIPouts = COALESCE(PitchIPouts, 0),
PitchH = COALESCE(PitchH, 0),
PitchER = COALESCE(PitchER, 0),
PitchHR = COALESCE(PitchHR, 0),
PitchBB = COALESCE(PitchBB, 0),
PitchSO = COALESCE(PitchSO, 0),
PitchBAOpp = COALESCE(PitchBAOpp, 0),
PitchERA = COALESCE(PitchERA, 0),
PitchIBB = COALESCE(PitchIBB, 0),
PitchWP = COALESCE(PitchWP, 0),
PitchHBP = COALESCE(PitchHBP, 0),
PitchBK = COALESCE(PitchBK, 0),
PitchBFP = COALESCE(PitchBFP, 0),
PitchGF = COALESCE(PitchGF, 0),
PitchR = COALESCE(PitchR, 0),
PitchSH = COALESCE(PitchSH, 0),
PitchSF = COALESCE(PitchSF, 0),
PitchGIDP = COALESCE(PitchGIDP, 0),
allStarCount = COALESCE(allStarCount, 0),
AllStar_MVP = COALESCE(AllStar_MVP, 0),
Babe_Ruth_Award = COALESCE(Babe_Ruth_Award, 0),
Cy_Young_Award = COALESCE(Cy_Young_Award, 0),
Gold_Glove_Award = COALESCE(Gold_Glove_Award, 0),
DH_Award = COALESCE(DH_Award, 0),
Pitching_Crown = COALESCE(Pitching_Crown, 0),
Relief_Award = COALESCE(Relief_Award, 0),
ROY_Award = COALESCE(ROY_Award, 0),
Silver_Slugger = COALESCE(Silver_Slugger, 0),
Batting_Crown = COALESCE(Batting_Crown, 0),
World_Series_MVP = COALESCE(World_Series_MVP, 0),
AL_MVP = COALESCE(AL_MVP, 0),
NL_MVP = COALESCE(NL_MVP, 0),
inducted = COALESCE(inducted, 0);

UPDATE SelectedFeaturesB
SET BatG = COALESCE(BatG, 0),
BatAB = COALESCE(BatAB, 0),
BatR  = COALESCE(BatR, 0), 
BatH  = COALESCE(BatH, 0), 
Bat2B = COALESCE(Bat2B, 0), 
Bat3B = COALESCE(Bat3B, 0), 
BatHR = COALESCE(BatHR, 0), 
BatRBI = COALESCE(BatRBI, 0),
BatSB = COALESCE(BatSB, 0),
BatCS = COALESCE(BatCS, 0),
BatBB = COALESCE(BatBB, 0),
BatSO = COALESCE(BatSO, 0),
BatIBB = COALESCE(BatIBB, 0),
BatHBP = COALESCE(BatHBP, 0),
BatSH = COALESCE(BatSH, 0),
BatSF = COALESCE(BatSF, 0),
BatGIDP = COALESCE(BatGIDP, 0),
FieldG = COALESCE(FieldG, 0),
FieldGS = COALESCE(FieldGS, 0),
FieldInnOuts = COALESCE(FieldInnOuts, 0),
FieldPO = COALESCE(FieldPO, 0),
FieldA = COALESCE(FieldA, 0),
FieldE = COALESCE(FieldE, 0),
FieldDP = COALESCE(FieldDP, 0),
FieldPB = COALESCE(FieldPB, 0),
FieldWP = COALESCE(FieldWP, 0),
FieldSB = COALESCE(FieldSB, 0),
FieldCS = COALESCE(FieldCS, 0),
FieldZR = COALESCE(FieldZR, 0),
PitchW = COALESCE(PitchW, 0),
PitchL = COALESCE(PitchL, 0),
PitchG = COALESCE(PitchG, 0),
PitchGS = COALESCE(PitchGS, 0),
PitchCG = COALESCE(PitchCG, 0),
PitchSHO = COALESCE(PitchSHO, 0),
PitchSV = COALESCE(PitchSV, 0),
PitchIPouts = COALESCE(PitchIPouts, 0),
PitchH = COALESCE(PitchH, 0),
PitchER = COALESCE(PitchER, 0),
PitchHR = COALESCE(PitchHR, 0),
PitchBB = COALESCE(PitchBB, 0),
PitchSO = COALESCE(PitchSO, 0),
PitchBAOpp = COALESCE(PitchBAOpp, 0),
PitchERA = COALESCE(PitchERA, 0),
PitchIBB = COALESCE(PitchIBB, 0),
PitchWP = COALESCE(PitchWP, 0),
PitchHBP = COALESCE(PitchHBP, 0),
PitchBK = COALESCE(PitchBK, 0),
PitchBFP = COALESCE(PitchBFP, 0),
PitchGF = COALESCE(PitchGF, 0),
PitchR = COALESCE(PitchR, 0),
PitchSH = COALESCE(PitchSH, 0),
PitchSF = COALESCE(PitchSF, 0),
PitchGIDP = COALESCE(PitchGIDP, 0),
allStarCount = COALESCE(allStarCount, 0),
AllStar_MVP = COALESCE(AllStar_MVP, 0),
Babe_Ruth_Award = COALESCE(Babe_Ruth_Award, 0),
Cy_Young_Award = COALESCE(Cy_Young_Award, 0),
Gold_Glove_Award = COALESCE(Gold_Glove_Award, 0),
DH_Award = COALESCE(DH_Award, 0),
Pitching_Crown = COALESCE(Pitching_Crown, 0),
Relief_Award = COALESCE(Relief_Award, 0),
ROY_Award = COALESCE(ROY_Award, 0),
Silver_Slugger = COALESCE(Silver_Slugger, 0),
Batting_Crown = COALESCE(Batting_Crown, 0),
World_Series_MVP = COALESCE(World_Series_MVP, 0),
AL_MVP = COALESCE(AL_MVP, 0),
NL_MVP = COALESCE(NL_MVP, 0),
inducted = COALESCE(inducted, 0);

