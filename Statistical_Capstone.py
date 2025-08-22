import pandas as pd
from scipy.stats import ttest_rel
import seaborn as sns
import matplotlib.pyplot as plt

# Load CSV
df = pd.read_csv("reserve_margin.csv")

# Function to prepare paired data
def prepare_paired(df, energy_type):
    subset = df[df["most_common_majority_type"] == energy_type]
    # Pivot so each country has both pre and post as separate columns
    pivoted = subset.pivot(index="Country", columns="year_range", values="mean_reserve_margin")
    # Drop countries missing one of the periods
    pivoted = pivoted.dropna()
    return pivoted

# Renewable countries
renewable_pivot = prepare_paired(df, "Majority Renewable")
t_renewable, p_renewable = ttest_rel(
    renewable_pivot["2010-2016"], renewable_pivot["2017-2023"]
)

# Fossil-fuel countries
fossil_pivot = prepare_paired(df, "Majority Non-Renewable")
t_fossil, p_fossil = ttest_rel(
    fossil_pivot["2010-2016"], fossil_pivot["2017-2023"]
)

print("Renewable countries (paired): t =", t_renewable, ", p =", p_renewable)
print("Fossil-fuel countries (paired): t =", t_fossil, ", p =", p_fossil)

# Plot
sns.barplot(
    data=df,
    x="most_common_majority_type",
    y="mean_reserve_margin",
    hue="year_range"
)
plt.ylabel("Mean Reserve Margin (MW)")
plt.title("Change in Reserve Margin Before and After 2017 by Energy Type")
plt.show()
