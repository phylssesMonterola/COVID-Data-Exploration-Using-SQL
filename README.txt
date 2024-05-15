This README file contains the steps that I did in solving some issues I encountered during importing process.

For some inexplicable reason, none of the importing methods that I used worked for me except for Import Flat File Method

Steps:

1. Make sure SQL Server Management Studio (SSMS) has a Server that ISN'T EXPRESS VERSION. Connect to the Server (Developer Version).

2. Create a Database. For this project sake, simply name it as COVID_Data_Exploration_Project

3. To import our data set:
-Right click on the Database, COVID_Data_Exploration_Project
-Tasks
-Import Flat File

4. The importation process is very straight forward, just follow what's told of you right until you finish. You are now all set with the data exploration project. More description and/or comments will be on the SQL code

Note: There's a part in the importing process where we get to modify data types of certain columns, it took a while but nothing too complicated. If we decide to change the data types later on, we can do it via a script/code.

Tip: You could always refer to the .csv files to check the data types of these columns while modifying said columns during the importation process

Check comments/description written on SQL for further info