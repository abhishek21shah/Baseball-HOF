#
# SETUP

# Ensure that the MasterF table exists
# This table is cleaned version of the Master table where all players that don't have valid debut and finalGame dates have been removed.

DROP TABLE IF EXISTS `MasterF`;
CREATE TABLE `MasterF` (
  `playerID` varchar(255),
  `daysActive` int DEFAULT 0,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# Count the days  active and remove any players that have 0 days active
INSERT INTO MasterF
SELECT playerID, TIMESTAMPDIFF(DAY, STR_TO_DATE(COALESCE(NULLIF(debut,''),'1970-01-01'), '%Y-%m-%d'), STR_TO_DATE(COALESCE(NULLIF(finalGame,''), '1970-01-01'), '%Y-%m-%d')) as daysActive
FROM Master
where TIMESTAMPDIFF(DAY, STR_TO_DATE(COALESCE(NULLIF(debut,''),'1970-01-01'), '%Y-%m-%d'), STR_TO_DATE(COALESCE(NULLIF(finalGame,''), '1970-01-01'), '%Y-%m-%d')) != 0;

# Ensure that the HallOfFameFA and HallOfFameFB Tables exist

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

# END SETUP
#

#
# Iteration 1

# Task A: The total number of instances
SELECT COUNT(*) as Task_A_Instances FROM 
MasterF m 
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID;

# Task A: The total number of players that belong to category 1 or 2
SELECT COUNT(*) as Task_A_Class_True FROM 
MasterF m 
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID
WHERE hoff.inducted = 1;

# Task A: The total number of players that belong to category 3
SELECT COUNT(*) as Task_A_Class_False FROM 
MasterF m 
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID
WHERE ISNULL(hoff.inducted);


# Task B: The total number of instances
SELECT COUNT(*) as Task_B_Instances FROM 
MasterF m 
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID;

# Task B: The total number of players that belong in category 1
SELECT COUNT(*) as Task_B_Class_True FROM 
MasterF m 
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID
WHERE hoff.inducted = 1;

# Task B: The total number of players that belong in category 2
SELECT COUNT(*) as Task_B_Class_False FROM 
MasterF m 
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID
WHERE hoff.inducted = 0;

# End iteration 1
#


#
# Iteration 2 and 3

# Task A: The total number of instances
SELECT COUNT(*) as Task_A_Instances FROM 
Master m 
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID;

# Task A: The total number of players that belong to category 1 or 2
SELECT COUNT(*) as Task_A_Class_True FROM 
Master m 
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID
WHERE hoff.inducted = 1;

# Task A: The total number of players that belong to category 3
SELECT COUNT(*) as Task_A_Class_False FROM 
Master m 
LEFT OUTER JOIN HallOfFameFA hoff ON m.playerID = hoff.playerID
WHERE ISNULL(hoff.inducted);


# Task B: The total number of instances
SELECT COUNT(*) as Task_B_Instances FROM 
Master m 
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID;

# Task B: The total number of players that belong in category 1
SELECT COUNT(*) as Task_B_Class_True FROM 
Master m 
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID
WHERE hoff.inducted = 1;

# Task B: The total number of players that belong in category 2
SELECT COUNT(*) as Task_B_Class_False FROM 
Master m 
INNER JOIN HallOfFameFB hoff ON m.playerID = hoff.playerID
WHERE hoff.inducted = 0;

# End iteration 2 and 3
#