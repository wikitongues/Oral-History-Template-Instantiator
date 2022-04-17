'use strict';

var fieldNames = require('./fieldNames');

var Airtable = require('airtable');
var fs = require('fs');
var single = process.argv[2];
var local = process.argv[3]
var destination = process.argv[4]
var fileIdentifier = process.argv[5]
require('dotenv').config({ path: local+"/.env" });


var base = new Airtable({apiKey: process.env.APIKEY}).base(process.env.BASE);

base('Oral Histories').select({
    view: ".LOCMetadataView",
    cellFormat: "string",
    timeZone: "America/New_York",
    userLocale: "en-ca",
    filterByFormula: "Identifier='"+single+"'",
    fields: [
      fieldNames.ID,
      fieldNames.LANGUAGE_ISO,
      fieldNames.LANGUAGE_ETHNOLOGUE_NAME,
      fieldNames.LANGUAGE_SPEAKER_PREFERRED_NAME,
      fieldNames.CREATOR_SPEAKERS,
      fieldNames.SELF,
      fieldNames.CREATOR,
      fieldNames.SUBJECT_LANGUAGE_NATION,
      fieldNames.COVERAGE_VIDEO_TERRITORY,
      fieldNames.DESCRIPTION,
      fieldNames.RIGHTS,
      fieldNames.YOUTUBE_PUBLISH_DATE,
      fieldNames.WIKIMEDIA_ELIGIBILITY,
      fieldNames.COVERAGE_WIKIMEDIA_COMMONS
    ]
}).eachPage(function page(records, fetchNextPage) {
  if (!Array.isArray(records) || !!records.length) {
    records.forEach(function(record) {
        const content = `Metadata for ${record.get(fieldNames.ID)}

Oral History ID:  ${record.get(fieldNames.ID)}
Languages by ISO 639-3 Code: ${record.get(fieldNames.LANGUAGE_ISO)}
Language Names: ${record.get(fieldNames.LANGUAGE_ETHNOLOGUE_NAME)}
Alternate Names: ${record.get(fieldNames.LANGUAGE_SPEAKER_PREFERRED_NAME)}
Speakers: ${record.get(fieldNames.CREATOR_SPEAKERS)}

Video Description: ${record.get(fieldNames.DESCRIPTION) || ''}

Original Submitter: ${record.get(fieldNames.CREATOR)}
Licenses: ${record.get(fieldNames.RIGHTS)}
Video Nation: ${record.get(fieldNames.SUBJECT_LANGUAGE_NATION)}
Video Territory: ${record.get(fieldNames.COVERAGE_VIDEO_TERRITORY)}

Published to Youtube on: ${record.get(fieldNames.YOUTUBE_PUBLISH_DATE)}
Wikimedia Status: ${record.get(fieldNames.WIKIMEDIA_ELIGIBILITY)}
Wiki Commons URL: ${record.get(fieldNames.COVERAGE_WIKIMEDIA_COMMONS)}`;

        fs.writeFileSync(`${destination}/${fileIdentifier}/${record.get(fieldNames.ID)}__metadata.txt`, content);
    });
    fetchNextPage();
  } else {
    console.log(`\x1b[31mWarning! ID '${single}' not found on airtable.`)
  }
}, function done(err) {
    if (err) { console.error(err); return; }
});