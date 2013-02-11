elephant-bird-intro
===================

An introduction to elephant-bird on the Hortonworks Blog

## About Elephant-Bird

From [elephant-bird](https://github.com/kevinweil/elephant-bird):

Elephant Bird is Twitter's open source library of LZO, Thrift, and/or Protocol Buffer-related Hadoop InputFormats, OutputFormats, Writables, Pig LoadFuncs, Hive SerDe, HBase miscellanea, etc. The majority of these are in production at Twitter running over data every day.

## Installing Elephant-Bird

Clone elephant-bird from github and build the package:

```
git clone git@github.com:kevinweil/elephant-bird.git
mvn package
```

For more info on building elephant-bird see [elephant-bird](https://github.com/kevinweil/elephant-bird).

## Loading JSON

Elephant-bird creates Pig maps from arbitrary JSON data. Download some JSON data: [A Million Syllabi](http://www.infochimps.com/datasets/a-million-syllabi).

Uncompress the data:

```
bzip2 -d infochimps_syllabus_catalog_entry.bz2
```

Remove Infochimps header (which isn't JSON???):

```
cat infochimps_syllabus_catalog_entry |perl -ne 'print unless /^infochimps_syllabus_catalog_entry/' > infochimps_syllabus_catalog_entry.json
```

Load the data into Pig. Assuming pig and elephant-bird and pig are installed at /me/Software (change for your setup).

```
register /me/Software/elephant-bird/core/target/elephant-bird-core-3.0.8-SNAPSHOT.jar
register /me/Software/elephant-bird/pig/target/elephant-bird-pig-3.0.8-SNAPSHOT.jar
register /me/Software/pig//build/ivy/lib/Pig/guava-11.0.jar
register /me/Software/pig//build/ivy/lib/Pig/json-simple-1.1.jar

syllabi = load 'infochimps_syllabus_catalog_entry.json' using com.twitter.elephantbird.pig.load.JsonLoader();
some_fields = foreach syllabi generate $0#'title' as title:chararray, $0#'chnm_cache' as html_content;
just_title = foreach some_fields generate title;
a = limit just_title 20;
dump a
```

The result is:

```
(REVISED PH.D HNDBK. 97-98.)
(History 331 Syllabus, Roman Imperial History)
(History 331 Syllabus, Roman Imperial History)
(History 331 Syllabus, Roman Imperial History 2002)
(Unit 2 Syllabus)
(CPO 3720 Syllabus)
(Health Policy and Management - about)
(Syllabus Submission, Summer Session 2002: Columbia University ...)
(New York City Undergraduate Area Research Program: Poverty, the ...)
(Contents)
(Syllabus)
(Syllabus:)
(Course Syllabus)
(Latin 100: Summer 1999)
(Advanced Oral Expression)
(KSU 4401 Syllabus Fall 2008)
(CS 387H Database Implementation)
(Syllabus for Gender and Literature)
(Italian Renaissance Art: Syllabus of Lectures)
(PON : Clearinghouse Launches Syllabus Collection)
```

## Loading SequenceFiles

Elephant-bird provides support for loading SequenceFiles in Pig via SequenceFileLoader. To start, download a sample SequenceFile from the [Common Crawl](http://commoncrawl.org) containing data for the crawl in Text format (it is a 35MB SequenceFile). More about this file is available [here](https://commoncrawl.atlassian.net/wiki/display/CRWL/About+the+Data+Set). More about this format is available on the [Hadoop wiki](http://wiki.apache.org/hadoop/SequenceFile).

A great example from Doug Daniels is available [here](https://gist.github.com/ddaniels888/4247553). Download and setup [s3cmd](http://s3tools.org/s3cmd) if you haven't already, and grab the data.

```
s3cmd get s3://aws-publicdatasets/common-crawl/parse-output/segment/1341690169105/textData-00112
```

Next up, load the file in Pig:

```
register /me/Software/elephant-bird/core/target/elephant-bird-core-3.0.8-SNAPSHOT.jar
register /me/Software/elephant-bird/pig/target/elephant-bird-pig-3.0.8-SNAPSHOT.jar
crawl_text = load 'textData-00112' using com.twitter.elephantbird.pig.load.SequenceFileLoader() as (url:chararray, body:chararray);
urls = foreach crawl_text generate url;
a = limit urls 20;
dump a
```

The result is:

```
(http://jdsitecare.com/tag/value/)
(http://jdsitecare.com/tag/value/feed/)
(http://moscowsnookerclub.ru/news/2008-10-01)
(http://www.cssweb.de/templates/show/preview/)
(http://www.columnist.com/Band_and_DJ_Electronics)
(http://www.facmed-sba.com/t2564-coucou-je-suis-la)
(http://www.weight-loss-detox.net/tag/detox-program/)
(http://m2m.kredyty-ubezpieczenia.eu/ubezpieczenieauta/)
(http://www.kubandom.ru/commercial/realty_v/2/22/price/1500000)
(http://www.webcamdomain.com/live-sex-chat/cam-girls/EvilJasmine)
(http://www.blackstormpaintball.com.ar/tag/product/list/tagId/96/)
(http://www.huwelijksdjs.nl/noord-brabant/waalwijk/hotel_waalwijk.html)
(http://erdic.homemilano.com/tag/%EC%A0%95%EC%9D%80%EA%B6%90%EC%86%8C%EC%84%A4)
(http://www.golfplatzfinder.com/merkzettel_golf-club-eschenrod.html#merkzettel)
(http://www.darmanin.ca/Properties.php/Details/14/403-14824-north-bluff-road-belaire-white-rock-bc)
(http://store.erenergy.com/store/product/20631/LE-CREUSET-1.25QT-PRECISION-POUR-SAUCPAN-COBALT-BLUE/)
(http://www.jobsinhonolulu.com/articles/title/How-to-network-and-job-search-when-you-have-a-job/5917/407)
(http://shop.moebel-kranz.de/online-shop/produkte-4-finder-201/wohnen-Moebel-Kranz-Uelzen/Essen-Schneller-finden-Glaeser.html)
(http://www.jobs4southyorkshire.co.uk/Administrator,Secretary-154988/trainee-personal-trainer-fitness-instructor-_1044752.aspx)
(http://www.assurance-valence.com/courtier-assurance/Assurance+particuliers+et+entreprises-+responsabilite+civile+mandataires+sociaux+RCMS+a-Guilherand+Granges-932.html)
```

