'use strict';
var Airtable = require('airtable');
var fs = require('fs');
var local = process.argv[3]
var destination = process.argv[4]
require('dotenv').config({ path: local+"/.env" });

var single = process.argv[2];
var base = new Airtable({apiKey: process.env.APIKEY}).base(process.env.BASE);

base('🍩 Oral Histories').select({
    view: ".LOCMetadataView",
    cellFormat: "string",
    timeZone: "America/New_York",
    userLocale: "en-ca",
    filterByFormula: "IDV2='"+single+"'",
    fields: [
      "IDv2",
      "Languages by ISO Code",
      "Languages Used",
      "Alternate Name",
      "Speakers",
      ".self?",
      "Source",
      "Video Nation",
      "Video Territory",
      "Video Description",
      "Licenses",
      "Youtube Publish Date",
      "Wikimedia Eligibility",
      "Wiki Commons URL"
    ]
}).eachPage(function page(records, fetchNextPage) {
  if (!Array.isArray(records) || !!records.length) {
    records.forEach(function(record) {
        const content = [`Metadata for ${record.get('IDv2')}

Oral History ID:  ${record.get('IDv2')}
Languages by ISO 639-3 Code: ${record.get('Languages by ISO Code')}
Language Names: ${record.get('Languages Used')}
Alternate Names: ${record.get('Alternate Name')}
Speakers: ${record.get('Speakers')}

Video Description: ${record.get('Video Description')}

Original Submitter: ${record.get('Source')}
Licenses: ${record.get('Licenses')}
Video Nation: ${record.get('Video Nation')}
Video Territory: ${record.get('Video Territory')}

Published to Youtube on: ${record.get('Youtube Publish Schedule')}
Wikimedia Status: ${record.get('Wikimedia Status')}
Wiki Commons URL: ${record.get('Wiki Commons URL')}`]

        fs.writeFileSync(`${destination}/${single}/${record.get('IDv2')}__metadata.txt`, content);
    });
    fetchNextPage();
  } else {
    console.log(`\x1b[31mWarning! ID '${single}' not found on airtable.`)
  }
}, function done(err) {
    if (err) { console.error(err); return; }
});