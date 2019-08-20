# FIRST: Make a folder somewhere on your computer, called something logical like "R Refresher Workshop."

# Now open RStudio (I'll do a little recap here). Make a new R Project (.Rproj) called 'session_1' that lives within the folder you just made. That will create a folder, and everything directly in that project folder will be in the *working directory.* Notice there is also a .Rproj file created - I think of that as a bow that ties all the files dropped into that project folder together. That is amazing because then you don't have to worry about obscure/complicated absolute file paths that work uniquely on your computer. Since files within the project folder are bound together in the project, and exist in the working directory, then when you open the project those files are going to be pointed to immediately just by calling their name. Basically, a project means when you read in data it can look something like this:

# read_csv("data_name.csv")

# Instead of:

# read_csv("C://user/yourname/an/obscure/impossible/filepath.csv")

# Which means that your file path is not machine or user specific...and that is a big plus for reproducibility & collaboration.

# OK. Once you have the project folder created, drop the data file (National Parks Visitation Data.csv) into the 'session_1' project folder. It should automatically show up in the files tab in RStudio for that project.

# Now, create a new R script (File > New File > R Script), and:

#-------------------------
# Make a nice header!
# These aren't active code b/c they're after a # (comments)
# Name
# Date
# Descriptive title
#-------------------------

#-------------------------
# 1. Attach required packages
#-------------------------

library(tidyverse) # Attach the tidyverse package
library(janitor) # Attach the janitor package

#-------------------------
# 2. Import the National Parks data
#-------------------------

np_data <- read_csv("session_1/National Parks Visitation Data.csv") # Note: if you just dropped the file into your project folder (not into a subfolder called 'session_1'), then you'd just have read_csv("file_name.csv") here.

# Note: the session_1 is included because it's within a subfolder in the project

#-------------------------
# 3. Check it out a little bit
#-------------------------

# Ask: do I want to be able to reproduce this exploration? If YES, then include in script. If NO, then you can just run them in the Console.

# Some functions to explore: View, names, dim, summary, head, tail. Show here that head(10) will get first 10 rows...default head() is first 6 rows, but you can specify however many you want.

#------------------------
# 4. Clean up the names using janitor::clean_names(
#------------------------

np_data <- clean_names(np_data)

#------------------------
# 5. dplyr::select to subset by columns
#------------------------

# dplyr::select example 1: keep sequential columns from parkname to year_raw:
np_select_1 <- select(np_data, parkname:year_raw) # Check out the output

# Another way to do this (and meet the pipe operator for the first time...)
np_select_1_pipe <- np_data %>% select(parkname:year_raw) # Cool!

# From now on, I'll use the pipe (we'll see later on why this is especially useful in combo with other functions).

# dplyr::select example 2: keep non-sequential columns state, name, and visitors:
np_select_2 <- np_data %>% select(state, name, visitors)

# dplyr::select example 3: keep some sequential, and some non-sequential columns (want to end up with region, then type through year_raw)
np_select_3 <- np_data %>% select(region, type:year_raw)

# dplyr::select example 4: both of the above, but then exclude a column (this will keep all columns from parkname through type, then exclude the code column, and also keep year_raw)
np_select_4 <- np_data %>% select(parkname:type, -code, year_raw)

#------------------------
# 6. dplyr::filter to conditionally subset by rows
#------------------------

# Use == to look for matches, != for 'does not match', expected less than/greater than alligator mouths.
# For "AND" statements, use &
# For "OR" statements, use |
# To match multiples, use %in% c("list","of","matching","strings")

# dplyr::filter example 1: only keep rows where the entry in column 'name' matches "Crater Lake National Park" (land at the intersection of Klamath, Umpqua, Takelma & Molala cultures)

np_filter_1 <- np_data %>% filter(name == "Crater Lake National Park")

# dplyr::filter example 2: only keep rows where entry in column 'name' matches "Acadia National Park" (native peoples: Wabanaki, or “People of the Dawnland”) AND (&) the entry in 'year_raw' column is greater than or equal to 2005:

np_filter_2 <- np_data %>% filter(name == "Acadia National Park" & year_raw >= 2005)

# dplyr::filter example 3: keep any rows where the observation in the 'state' column matches "CA", "OR", or "WA":

np_filter_3 <- np_data %>% filter(state %in% c("CA","OR","WA"))

# dplyr::filter example 4: keep any rows EXCEPT those where observation in the 'type' column is "National Park":

np_filter_4 <- np_data %>% filter(type != "National Park")

#------------------------
# 7. dplyr::rename to rename columns
#------------------------

# Use format: rename(new_name = old_name)
# For example, to rename the existing column 'type' as 'park_type':
np_rename_1 <- np_data %>% rename(park_type = type)

#------------------------
# 8. dplyr::mutate to overwrite (careful) or add (safer!) a new column
#------------------------

# dplyr::mutate example 1: Add a new column (visitors_mill) that is the number of visitors divided by 10^6 (to convert to "millions of visitors"):
np_mutate_1 <- np_data %>% mutate(visitors_mill = visitors/1e6)

# Note: you can also use mutate to convert variables by class (factor, as.character, as.numeric, etc.)

#------------------------
# 9. dplyr::mutate + dplyr::case_when to conditionally add a new column
#------------------------

# Let's say that I want to create a new column, 'type_simple': anywhere the  existing 'type' column matches "National Park" then 'type_simple' should contain "NP", and anywhere the existing 'type' column is "National Monument" then 'type_simple' should contain "NM", and for all other types, the new column should contain "other".

# I'll use mutate + case_when to add a new column (that's where mutate comes in) that is conditional based on an existing column (that's what case_when does).

np_mutate_cw_1 <- np_data %>%
  mutate(
    type_simple = case_when(
      type == "National Park" ~ "NP",
      type == "National Monument" ~ "NM",
      T ~ "other"
    )
  )

# And what if everytime year_raw is lower than 2000, a new column (century) contains "twentieth", and every time year_raw is greater than or equal to 2000, century contains "twentyfirst":

np_mutate_cw_2 <- np_data %>%
  mutate(
    century = case_when(
      year_raw < 2000 ~ "twentieth",
      year_raw >= 2000 ~ "twentyfirst"
    )
  )

# You can also use case_when for conditional computation (useful e.g. if you have data in different units, and you want to have a column where they are all converted to the same units...)

#------------------------
# 10. dplyr::group_by + summarize to make calculations by groups within specified variables
#------------------------

# Let's say that I want to calculate the TOTAL visitors to all National Parks in California. The steps I'm going to take are: (1) Filter to only include National Parks in California, (2) group by name using group_by, (3) find the sum of the visitor column for each group using summarize.

np_group_by_1 <- np_data %>%
  filter(type == "National Park" & state == "CA") %>% # This filters to only include National Parks in CA
  filter(year_raw != "Total") %>% # Get rid of the "Total" sums
  group_by(name) %>% # This creates "invisible" groupings
  summarize( # This steps allows for calculations by group
    tot_visitors = sum(visitors)
  )

# You can also have multiple operations on groups within summarize(). For example, if I want to calculate the total number of visitors, then find the maximum annual visitors and the minimum annual visitors recorded for each park:

np_group_by_2 <- np_data %>%
  filter(type == "National Park" & state == "CA") %>%
  filter(year_raw != "Total") %>%
  group_by(name) %>%
  summarize(
    tot_visitors = sum(visitors),
    max_visitors = max(visitors),
    min_visitors = min(visitors)
  )

# You can also group by multiple variables. Let's say I want to first group by region, then by type, then find the counts of each:

np_group_by_3 <- np_data %>%
  group_by(region, type) %>%
  tally() # This is a great way to get counts of observations for groups

#------------------------
# 11. tidyr::unite() + tidyr::sep()
# -----------------------

# Sometimes you'll want to either combine information from two columns, or separate information that exists within a single column. For example, let's say I want to have a single column that contains the Region and State, separated by a comma (not sure why you'd want to do that, but whatever).

# To combine information from separate variables (columns), use tidyr::unite() in combination with mutate() to add the new combined column:

np_unite <- np_data %>%
  unite(united_stuff, c(region, state), sep = ",", remove = FALSE) # note: if you set 'remove = TRUE', this will remove the original variables that have been combined (that's the default)

# To separate information in a single column (into two columns), use tidyr::separate(). More information: https://tidyr.tidyverse.org/reference/separate.html

#------------------------
# Graphs with ggplot2
#------------------------

# Graph Example 1:
# I want to make a line graph of visitation to Yosemite (Ahwahnechee, of Miwok peoples: https://blogs.scientificamerican.com/primate-diaries/how-john-muir-s-brand-of-conservation-led-to-the-decline-of-yosemite/). First, I'm going to filter to only include Yosemite National Park, and only keeping columns 'name', 'year_raw', and 'visitors'. Then I'm going to make a graph of it.

yosemite <- np_data %>%
  filter(name == "Yosemite National Park", year_raw != "Total") %>%
  select(name, year_raw, visitors) %>%
  arrange(year_raw) %>%
  mutate(year_raw = as.numeric(year_raw)) # Explain why we need to do this: that 'Total' in the original df means that the ENTIRE COLUMN was read in as a character. We want R to understand it as a number. This is one case where using mutate to overwrite a column (instead of adding a new one) actually makes sense.

# Cool, now that's a manageable dataset. Let's make a graph of it!

ggplot(yosemite, aes(x = year_raw, y = visitors)) +
  geom_line()

# Any customization we can add as additional layers (notice here: using a + instead of the pipe)!

ggplot(yosemite, aes(x = year_raw, y = visitors)) +
  geom_line(color = "purple", size = 0.5, lty = 3) +
  theme_bw() +
  labs(x = "Year", y = "Annual Visitors")

# Graph Example 2:
# I want to make a line graph of annual visitors to all National Parks in each REGION over the years. First I'm going to filter to only include National Parks, then group_by region AND year, then find the sum, then make a multi-series line graph.

region_np <- np_data %>%
  filter(type == "National Park", year_raw != "Total") %>%
  mutate(year_raw = as.numeric(year_raw)) %>%
  group_by(region, year_raw) %>%
  summarize(
    annual_sum = sum(visitors)
  )

# Now I'll make a graph of it:
quartz() # Show that you can use this to open graphics window, or windows() on a PC
ggplot(region_np, aes(x = year_raw, y = annual_sum, group = region)) +
  geom_line(size = 0.1, aes(color = region)) +
  geom_point(size = 0.5, aes(color = region)) +
  theme_light()

# Graph Example 3: I want to make a bar graph of the total number of each type of park (counts).

np_type_counts <- np_data %>%
  group_by(type) %>%
  tally()

# Now I'll make a column graph of counts:

ggplot(np_type_counts, aes(x = type, y = n)) +
  geom_col() +
  coord_flip()

# What if I want to have them shown from high to low counts? Notice that they're arranged alphabetically here.

np_type <- np_data %>%
  group_by(type) %>%
  tally() %>%
  arrange(-n)

# So that's kind of annoying, especially when you make a graph w/categories and they show up alphabetically instead of in the order you expect. When that happens, factor reorder (using forcats::fct_reorder; see also forcats::fct_relevel if you want to explicitly set the order, e.g. for character levels)

np_type_new <- np_type %>%
  mutate(type = fct_reorder(type, n))

quartz()
ggplot(np_type_new, aes(x = type, y = n)) +
  geom_col(aes(fill = n)) +
  scale_fill_gradient(low = "purple", high = "red") +
  coord_flip() +
  theme_minimal()

#--------------------
# END OF SESSION 1
#--------------------

#--------------------
# SESSION 1 PRACTICE: Women's World Cup data
# Data from: data.world (https://data.world/sportsvizsunday/womens-world-cup-data)
#--------------------

# For this task, you will find and visualize the 10 all-time top-scoring squads in the Women's World Cup. The worked solutions for this task (parts f - m) are included below. You will read in data directly from a website.

# a. Create a new R Project (.Rproj)
# b. Within in the project, create a new R script
# c. Add a useful header, and remember to add thorough comments throughout
# d. Attach the 'tidyverse' package
# e. Read in the Women's World Cup outcomes data by adding the following (and running) in your script! (Question: why would you want to include this as a line of code in your script, instead of running it in the Console?)

wwc_outcomes <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-09/wwc_outcomes.csv")

# f. Explore the dataset using base R functions View, head, tail, dim, names, summary. Think about: do you want this in your script (where it will be run every time you run the script), or do you want to do this in the Console?

# g. Create a new df called 'wwc_goals' that only retains columns 'team', 'year' and 'score'. Hint: dplyr::select()

# h. Starting from the wwc_goals subset, in a piped sequence use group_by + summarize to calculate the total number of goals scored by each *team* in *each World Cup year* (hint: group_by() both team and year, then sum). Store the outcome table as 'wwc_sep', with the summed goals in as a variable called 'goals'.

# i. In a piped sequence, arrange wwc_sep from high-to-low by total goals scored, and keep only the top 10 scoring teams across all WWC years. Store this arranged and shortened dataset as 'top_scoring_squads'.

# j. From the 'top_scoring_squads' df, combine the 'team' and 'year' columns from top_scoring_squads into a single column called 'country_yr', separated by a space. Hint: tidyr::unite(). Call the dataset with the combined column 'top_score_united'.

# k. From the 'top_score_united' df, create a bar graph of the top 10 scoring teams, with the united team and year information ('country_yr') on the x-axis. Customize your graph.

# l. Save your script. Close R (do not save the workspace).

# m. Click on the .Rproj file you created to reopen it. Open the script you wrote to do this practice task. Re-run everything (Command + Shift + Enter) to ensure that you can reproduce everything right away. Hooray reproducibility!

# Congratulations, see you in the next session! -Allison

#----------------------
# SESSION 1 PRACTICE TASK PARTS F - M SOLUTIONS:
#----------------------

# f. Explore the dataset using base R functions View, head, tail, dim, names, summary. Think about: do you want this in your script (where it will be run every time you run the script), or do you want to do this in the Console?

names(wwc_outcomes)
View(wwc_outcomes)
head(wwc_outcomes)
tail(wwc_outcomes)
summary(wwc_outcomes)

# Task: Find and visualize the 10 all-time top-scoring squads in the Women's World Cup:

# g. Create a new df called 'wwc_goals' that only retains columns 'team', 'year' and 'score'. Hint: dplyr::select()

wwc_goals <- wwc_outcomes %>%
  select(team, year, score)

# h. Starting from the wwc_goals subset, in a piped sequence use group_by + summarize to calculate the total number of goals scored by each *team* in *each World Cup year* (hint: group_by() both team and year, then sum). Store the outcome table as 'wwc_sep', with the summed goals in as a variable called 'goals'.

wwc_sep <- wwc_outcomes %>%
  group_by(team, year) %>%
  summarize(
    goals = sum(score)
  )

# i. In a piped sequence, arrange wwc_sep from high-to-low by total goals scored, and keep only the top 10 scoring teams across all WWC years. Store this arranged and shortened dataset as 'top_scoring_squads'.

top_scoring_squads <- wwc_sep %>%
  arrange(-goals) %>%
  head(10)

# j. From the 'top_scoring_squads' df, combine the 'team' and 'year' columns from top_scoring_squads into a single column called 'country_yr', separated by a space. Hint: tidyr::unite(). Call the dataset with the combined column 'top_score_united'.

top_score_united <- top_scoring_squads %>%
  unite(country_yr, c(team, year), sep = " ")

# k. From the 'top_score_united' df, create a bar graph of the top 10 scoring teams, with the united team and year information ('country_yr') on the x-axis. Customize your graph.

# First, I'm going to reorder the factor levels (you don't need to, but it makes it look nicer) using fct_reorder in the forcats() package:

top_score_order <- top_score_united %>%
  mutate(country_yr = fct_reorder(country_yr, goals)) # Note: this will OVERWRITE the existing country_yr column, with the newly reordered factor country_yr, since I haven't added a different column name!

# Then plot:

ggplot(top_score_order, aes(x = country_yr, y = goals)) +
  geom_col(aes(fill = country_yr)) +
  labs(x = "Squad",
       y = "Total goals in WWC",
       title = "Top 10 highest scoring teams in WWC history") +
  theme_bw() +
  scale_y_continuous(expand = c(0,0), limits = c(0,30)) +
  guides(fill = FALSE) + # This line removes the unnecessary legend
  coord_flip() # Flips the x- and y-axes (best to do this last to avoid confusion with labeling & updating the axes, etc.)

# l. Save your script. Close R (do not save the workspace).

# m. Click on the .Rproj file you created to reopen it. Open the script you wrote to do this practice task. Re-run everything (Command + Shift + Enter) to ensure that you can reproduce everything right away. Hooray reproducibility!

# Congratulations, see you in the next session! -Allison

#----------------------
# END SESSION 1 PRACTICE TASK
#----------------------




