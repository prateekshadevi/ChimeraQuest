# ChimeraQuest: Personalized Recommendation Engine

ChimeraQuest is an end-to-end data engineering project that moves away from traditional, flat genre-based recommendations (e.g., matching "Action" to "Action"). Instead, it breaks entities down into a granular "Mechanical DNA" taxonomy—evaluating shared gameplay elements like perspective, gameplay loops, and themes using cloud-scale matrix calculations.

---

## 🏗️ System Architecture

Our data pipeline moves linearly across four core architectural stages:

1. **Data Source:** Fetching semi-structured gameplay metadata from the Twitch/IGDB REST API.
2. **Ingestion & Processing:** Running a local Python/Jupyter pipeline to clean, parse, and flatten JSON payloads into optimized `.jsonl` lines.
3. **Cloud Data Warehouse:** Streaming data directly into Google BigQuery to run parallelized, high-volume self-joins and algorithmic similarity calculations.
4. **BI/Semantic Layer:** Visualizing data inside Power BI Desktop via an optimized local cache memory model using disconnected table filtering structures.

*(Note to User: Once you upload your diagram to GitHub, you can place your picture right here!)*

---

## 🛠️ Tech Stack & Skills Highlight
* **Languages:** Python (Requests, JSON parsing, Object manipulation), SQL (Google Standard SQL)
* **Cloud Infrastructure:** Google Cloud Platform (GCP), BigQuery Serverless Data Warehouse
* **Analytics & Business Intelligence:** Power BI Desktop, Power Query (M Engine), DAX Data Modeling

---

## 🧮 The Brain: Jaccard Similarity Engine

To determine how structurally similar two games are, the system bypasses string matches and computes a literal **Jaccard Similarity Index** inside BigQuery. 

The algorithm calculates the ratio of shared mechanical tags (the intersection) over total unique tags combined between the two games (the union):

$$J(A, B) = \frac{|A \cap B|}{|A \cup B|}$$

### The SQL Implementation Strategy
To achieve this calculation across millions of possible pairs efficiently, the pipeline applies a high-performance self-join loop:

```sql
-- Flattening array tags via UNNEST and generating pair combinations
WITH game_tags AS (
  SELECT name, tag
  FROM `your-project.dataset.raw_game_dna`, UNNEST(tags) AS tag
),
intersections AS (
  SELECT a.name AS game_a, b.name AS game_b, COUNT(*) AS shared_tags_count
  FROM game_tags a
  JOIN game_tags b ON a.tag = b.tag
  WHERE a.name < b.name -- Eliminates self-matching and duplicate inverted loops
  GROUP BY 1, 2
)