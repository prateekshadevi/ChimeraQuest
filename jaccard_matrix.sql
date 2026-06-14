CREATE OR REPLACE TABLE `chimera_quest_raw_dna.dna_similarity_matrix` AS
WITH game_tags AS (
  -- Flatten the tags
  SELECT
    name,
    tag
  FROM `project-94d74c6d-d1de-46a2-881.chimera_quest_raw_dna.raw_game_dna`,
  UNNEST(tags) AS tag
),

intersections AS (
  -- Self-join on table to find shared tags between pairs
  SELECT 
    a.name AS game_a,
    b.name AS game_b,
    COUNT(*) AS shared_tags_count
  FROM game_tags a
  JOIN game_tags b ON a.tag = b.tag
  WHERE a.name < b.name
  GROUP BY 1,2
),

tag_counts AS (
  -- Total unique tags for each game
  SELECT name, COUNT(*) as total_tags FROM game_tags GROUP BY 1
)

-- Jaccard Math: Intersection / Union
SELECT 
  i.game_a,
  i.game_b,
  i.shared_tags_count,
  (t1.total_tags + t2.total_tags - i.shared_tags_count) AS union_count,
  SAFE_DIVIDE(i.shared_tags_count, (t1.total_tags + t2.total_tags - i.shared_tags_count)) AS similarity_score
FROM intersections i
JOIN tag_counts t1 ON i.game_a = t1.name
JOIN tag_counts t2 ON i.game_b = t2.name
WHERE (i.shared_tags_count / (t1.total_tags + t2.total_tags - i.shared_tags_count)) > 0.3