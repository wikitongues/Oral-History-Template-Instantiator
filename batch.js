var fieldNames = require('./fieldNames');

var Airtable = require('airtable');
var fs = require('fs');
require('dotenv').config();

var dir = './dump';
if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
}

var base = new Airtable({apiKey: process.env.APIKEY}).base(process.env.BASE);

base('Oral Histories').select({
    // Selecting the first 3 records in Worksheet:
    // maxRecords: 3,
    view: ".LOCMetadataView",
    cellFormat: "string",
    timeZone: "America/New_York",
    userLocale: "en-ca",
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
    // This function (`page`) will get called for each page of records.

    records.forEach(function(record) {
        const content = [`Metadata for ${record.get('IDv2')}

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
Wiki Commons URL: ${record.get(fieldNames.COVERAGE_WIKIMEDIA_COMMONS)}`]
        
        fs.writeFileSync(`dump/${record.get('IDv2')}__metadata.txt`, content);
        console.log('wrote', record.get('IDv2'));
    });

    // To fetch the next page of records, call `fetchNextPage`.
    // If there are more records, `page` will get called again.
    // If there are no more records, `done` will get called.
    fetchNextPage();

}, function done(err) {
    if (err) { console.error(err); return; }
});