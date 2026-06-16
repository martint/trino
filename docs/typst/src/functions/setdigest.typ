#import "/lib/trino-docs.typ": *

#anchor("doc-functions-setdigest")
= Set Digest functions

Trino offers several functions that deal with the #link("https://wikipedia.org/wiki/MinHash")[MinHash] technique.

MinHash is used to quickly estimate the #link("https://wikipedia.org/wiki/Jaccard_index")[Jaccard similarity coefficient] between two sets.

It is commonly used in data mining to detect near-duplicate web pages at scale. By using this information, the search engines efficiently avoid showing within the search results two pages that are nearly identical.

The following example showcases how the Set Digest functions can be used to naively estimate the similarity between texts. The input texts are split by using the function #link(label("fn-ngrams"), raw("ngrams")) to #link("https://wikipedia.org/wiki/W-shingling")[4-shingles] which are used as input for creating a set digest of each initial text. The set digests are compared to each other to get an approximation of the similarity of their corresponding initial texts:

#code-block(none, "WITH text_input(id, text) AS (
         VALUES
             (1, 'The quick brown fox jumps over the lazy dog'),
             (2, 'The quick and the lazy'),
             (3, 'The quick brown fox jumps over the dog')
     ),
     text_ngrams(id, ngrams) AS (
         SELECT id,
                transform(
                  ngrams(
                    split(text, ' '),
                    4
                  ),
                  token -> array_join(token, ' ')
                )
         FROM text_input
     ),
     minhash_digest(id, digest) AS (
         SELECT id,
                (SELECT make_set_digest(v) FROM unnest(ngrams) u(v))
         FROM text_ngrams
     ),
     setdigest_side_by_side(id1, digest1, id2, digest2) AS (
         SELECT m1.id as id1,
                m1.digest as digest1,
                m2.id as id2,
                m2.digest as digest2
         FROM (SELECT id, digest FROM minhash_digest) m1
         JOIN (SELECT id, digest FROM minhash_digest) m2
           ON m1.id != m2.id AND m1.id < m2.id
     )
SELECT id1,
       id2,
       intersection_cardinality(digest1, digest2) AS intersection_cardinality,
       jaccard_index(digest1, digest2)            AS jaccard_index
FROM setdigest_side_by_side
ORDER BY id1, id2;")

#code-block("text", " id1 | id2 | intersection_cardinality | jaccard_index
-----+-----+--------------------------+---------------
   1 |   2 |                        0 |           0.0
   1 |   3 |                        4 |           0.6
   2 |   3 |                        0 |           0.0")

The above result listing points out, as expected, that the texts with the id #raw("1") and #raw("3") are quite similar.

One may argue that the text with the id #raw("2") is somewhat similar to the texts with the id #raw("1") and #raw("3"). Due to the fact in the example above #emph[4-shingles] are taken into account for measuring the similarity of the texts, there are no intersections found for the text pairs #raw("1") and #raw("2"), respectively #raw("3") and #raw("2") and therefore there the similarity index for these text pairs is #raw("0").

== Data structures

Trino implements Set Digest data sketches by encapsulating the following components:

- #link("https://wikipedia.org/wiki/HyperLogLog")[HyperLogLog]
- #link("http://wikipedia.org/wiki/MinHash#Variant_with_a_single_hash_function")[MinHash with a single hash function]

The HyperLogLog structure is used for the approximation of the distinct elements in the original set.

The MinHash structure is used to store a low memory footprint signature of the original set. The similarity of any two sets is estimated by comparing their signatures.

The Trino type for this data structure is called #raw("setdigest"). Trino offers the ability to merge multiple Set Digest data sketches.

== Serialization

Data sketches can be serialized to and deserialized from #raw("varbinary"). This allows them to be stored for later use.

== Functions

#function-def("fn-make-set-digest", "make_set_digest(x)", "setdigest")[
Composes all input values of #raw("x") into a #raw("setdigest").

Create a #raw("setdigest") corresponding to a #raw("bigint") array:

#code-block(none, "SELECT make_set_digest(value)
FROM (VALUES 1, 2, 3) T(value);")

Create a #raw("setdigest") corresponding to a #raw("varchar") array:

#code-block(none, "SELECT make_set_digest(value)
FROM (VALUES 'Trino', 'SQL', 'on', 'everything') T(value);")
]

#function-def("fn-merge-set-digest", "merge_set_digest(setdigest)", "setdigest")[
Returns the #raw("setdigest") of the aggregate union of the individual #raw("setdigest") Set Digest structures.
]

#anchor("ref-setdigest-cardinality")

#function-def("fn-cardinality-4", "cardinality(setdigest)", "long", ref: false)[
Returns the cardinality of the set digest from its internal #raw("HyperLogLog") component.

Examples:

#code-block(none, "SELECT cardinality(make_set_digest(value))
FROM (VALUES 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5) T(value);
-- 5")
]

#function-def("fn-intersection-cardinality", "intersection_cardinality(x,y)", "long")[
Returns the estimation for the cardinality of the intersection of the two set digests.

#raw("x") and #raw("y") must be of type  #raw("setdigest")

Examples:

#code-block(none, "SELECT intersection_cardinality(make_set_digest(v1), make_set_digest(v2))
FROM (VALUES (1, 1), (NULL, 2), (2, 3), (3, 4)) T(v1, v2);
-- 3")
]

#function-def("fn-jaccard-index", "jaccard_index(x, y)", "double")[
Returns the estimation of #link("https://wikipedia.org/wiki/Jaccard_index")[Jaccard index] for the two set digests.

#raw("x") and #raw("y") must be of type  #raw("setdigest").

Examples:

#code-block(none, "SELECT jaccard_index(make_set_digest(v1), make_set_digest(v2))
FROM (VALUES (1, 1), (NULL,2), (2, 3), (NULL, 4)) T(v1, v2);
-- 0.5")
]

#function-def("fn-hash-counts", "hash_counts(x)", "map(bigint, smallint)")[
Returns a map containing the #link("https://wikipedia.org/wiki/MurmurHash#MurmurHash3")[Murmur3Hash128] hashed values and the count of their occurences within the internal #raw("MinHash") structure belonging to #raw("x").

#raw("x") must be of type  #raw("setdigest").

Examples:

#code-block(none, "SELECT hash_counts(make_set_digest(value))
FROM (VALUES 1, 1, 1, 2, 2) T(value);
-- {19144387141682250=3, -2447670524089286488=2}")
]
