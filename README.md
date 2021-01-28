# Baseball-HOF

## Using the Sean Lahman [baseball dataset](https://www.kaggle.com/seanlahman/the-history-of-baseball) two different tasks were carried out.
1. Task A is to determine if any given player will be nominated to the Hall of Fame. 
2. Task B is to determine if a nominated player will be inducted into the Hall of Fame.

### A total of 3 iterations were carried out to improve the accuracy and precision of the model using the Decision Tree Classifier.
#### After feature refinement and selection was conducted at each iteration, hyperparameter tuning was performed to further improve the model.
1. Data not related to players was not used and only key tables that contained data for batting, pitching and fielding were used. Further data cleaning was done by:
* Converting textual data to numeric
* Certain awards that did not exist in the 19th and 20th century were dropped
* Null values were converted to 0
* While the accuracy for both Tasks was good, the precision for the two classes within each Task was not as good and a second iteration was conducted.
2. To improve the model a Gini importance threshold of 0.05 was used for every feature. Additionally many features had an importance of 0 and were dropped for this iteration.
* Only awards that are deemed good indicators for the HOF were included.
* Postseason data was also included.
* Another feature that was included was total active days. Players that have a long career are more likely to be nominated and inducted into the HOF.
* Post hyperparameter tuning the accuracy and precision were really high and a third iteration was done to see if results could be improved further.
3. Adding new features related to pitching and fielding were included, but that had marginal improvements on the accuracy and precision from the previous iteration.
