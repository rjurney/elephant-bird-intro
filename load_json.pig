register elephant-bird-core-3.0.8-SNAPSHOT.jar
register elephant-bird-pig-3.0.8-SNAPSHOT.jar
register /me/Software/pig//build/ivy/lib/Pig/guava-11.0.jar
register /me/Software/pig//build/ivy/lib/Pig/json-simple-1.1.jar

syllabi = load 'infochimps_syllabus_catalog_entry.json' using com.twitter.elephantbird.pig.load.JsonLoader();
some_fields = foreach syllabi generate $0#'title' as title:chararray, $0#'chnm_cache' as html_content;
just_title = foreach some_fields generate title;
a = limit just_title 20;
dump a
