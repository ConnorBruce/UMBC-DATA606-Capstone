## 1. Title and Author

- Forecasting DC Pavement Condition Using HPMS Data
- Prepared for UMBC Data Science Master Degree Capstone by Dr Chaojie (Jay) Wang
- Connor Bruce
- [Project GitHub](https://github.com/ConnorBruce/UMBC-DATA606-Capstone) 
- [LinkedIn](https://www.linkedin.com/in/connormbruce/) 
- Link to your PowerPoint presentation file
- Link to your YouTube video 
    
## 2. Background

Provide the background information about the chosen topic. 

- What is it about? 
- Why does it matter? 
- What are your research questions?

Transportation agencies such as State DOTs generate tons of data about their pavements, bridges, and ancillary assets and this data is extremely valuable for planning their funding and allocating their resources to ensure their transporation network functions properly and safely. Included in this data is the condition and traffic load on their network's pavement. This project intends to use that data to predict pavement deterioration based on the pavement designation and traffic load on Washington DC's pavement network. 

Similar analyses to this are used by these transporation agencies to make data-informed decisions on where to initiate construction projects to restore and reconstruct stretches of pavements. Pavements in good condition are both safer and financially advantageous to the community as there is less wear and tear on the vehicles that drive on them. Additionally, transportation agencies have limited funding, especially federal, so it's critical to optimize the funds they have to maximize the improvement to their transportation network.

Some questions this research hopes to answer are how traffic affects the deterioration of pavements taking into account the surface type of the pavement and the pavement's designation. Further, a secondary question this aims to answer is what the network will look like in the future. Using the Highway Performance Monitoring System (HPMS) data from 2016-2024, a model will be built that predicts and applies a deterioration rate to the pavement and, assuming no work is done on the pavement, can predict out multiple years.

## 3. Data 

Describe the datasets you are using to answer your research questions.

- Data sources
- Data size (MB, GB, etc.)
- Data shape (# of rows and # columns)
- Time period (for example, 2010 to 2020) if your data are time-bound
- **What does each row represent?(a patient, a school, a crime, etc.)**
- Data dictionary
  - Columns name
  - Data type
  - Defition
  - Potential values (for categorical valuables, what are the categories?)
- Which variable/column will be your target/label in your ML model?
- Which variables/columns may be selected as features/predictors for your ML models?

**Data Source:** [DC HPMS Data](https://hub.arcgis.com/datasets/0a0342b71f80483d810fed44afd86014/about) (282.8 MB)

**Data Shape:**
- Pre-processed: 1,727,332 rows x 40 columns
- Post-processed: 1,480,386 rows x 11 columns

**Data Time Period:** 2015-2024

**Data Description:**
- Contains the HPMS submittal data from 2015 to 2024 for DC in geodatabase format.
- When all years joined, each row represents a section of highway for a given year and includes information about road designation, traffic, and pavement condition

**Data Dictionary:**
| Column Name  | Data Type  | Definition  | Potential Values  |  
|---|---|---|---|
| ROUTE_ID  |  Character |  Route Designation Identifier | Any alphanumeric combination  |   
| BEGIN_POINT  | Numeric  | Mile marker of starting point for section  | Any real number >= 0 and less than END_POINT  |  
| END_POINT  |  Numeric | Mile marker of ending point for section  | Any real number > 0 and greater than BEGIN_POINT  |   
| YEAR_RECORD  | Integer  | Year of given observation  | Integer between 2015 and 2024, inclusive  |  
| AADT  | Integer  | Average Annual Daily Traffic. Average number of cars that drove on given section of road per day for given year  |  Integer >= 0 |   
| IRI  | Integer  | Internation Roughness Index (IRI) value for given section. In units of in/mi  |  Integer >= 0 |
| F_SYSTEM  |  Integer | Code for functional system of given section. (e.g. Interstate, Major Arterial, Minor Arterial)  | Integer between 0 and 7, inclusive  |   
| NHS  |  Integer | Indicates whether the road is part of the National Highway System (NHS)  | Integer between 0 and 7, inclusive  |   
| SURFACE_TYPE  |  Integer | Code for material of given section's pavement surface  | Integer between 0 and 11, inclusive  | 
| IRI_DELTA  |  Integer | Year-over-year change in IRI, in in/mi  |  Integer >= 0 |   
| AADT_DELTA  | Integer  |  Year-over-year change in AADT | Integer >= 0  |

**Machine Learning Model Target:** The target field for the model will be the IRI Delta, or the year-over-year change in IRI. This value is critical for predicting the rate of deterioration for an agency's pavement, allowing them to anticipate where to allocate resources to optimize system improvement.

**Features and Predictors:**
- AADT: Traffic causes wear and tear on a road and is useful for estimating changes in pavement condition
- F_SYSTEM: Different functional classes recieve different amounts of attention and repairs, therefore, it is helpful to include this feature to include these differences.
- NHS: Similar to functional class, pavements on the NHS are required to recieve a certain amount of funding and are typically given more repairs and funding. Additionally, highway traffic is different than other road's traffic.
- SURFACE_TYPE: Different surface types (e.g. Asphalt vs. Concrete) behave differently over time.
- AADT_DELTA: Changes in traffic over time can affect pavements, especially in flexible asphalt pavements.
- IRI: Roads in different conditions may deteriorate at different rates.


## 4. Exploratory Data Analysis (EDA)

- Perform data exploration using Jupyter Notebook
- You would focus on the target variable and the selected features and drop all other columns.
- produce summary statistics of key variables
- Create visualizations (I recommend using **Plotly Express**)
- Find out if the data require cleansing:
  - Missing values?
  - Duplicate rows? 
- Find out if the data require splitting, merging, pivoting, melting, etc.
- Find out if you need to bring in other data sources to augment your data.
  - For example, population, socioeconomic data from Census may be helpful.
- For textual data, you will pre-process (normalize, remove stopwords, tokenize) them before you can analyze them in predictive analysis/machine learning.
- Make sure the resulting dataset need to be "tidy":
  - each row represent one observation (ideally one unique entity/subject).
  - each columm represents one unique property of that entity. 

## 5. Model Training 

- What models you will be using for predictive analytics?
- How will you train the models?
  - Train vs test split (80/20, 70/30, etc.)
  - Python packages to be used (scikit-learn, NLTK, spaCy, etc.)
  - The development environments (your laptop, Google CoLab, GitHub CodeSpaces, etc.)
- How will you measure and compare the performance of the models?

## 6. Application of the Trained Models

Develop a web app for people to interact with your trained models. Potential tools for web app development:

- **Streamlit** (recommended for its simplicity and ease to learn)
- Dash
- Flask

## 7. Conclusion

- Summarize your work and its potetial application
- Point out the limitations of your work
- Lessons learned 
- Talk about future research direction

## 8. References 

List articles, blogs, and websites that you have referenced or used in your project.
