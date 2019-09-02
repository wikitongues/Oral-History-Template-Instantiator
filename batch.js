var Airtable = require('airtable');
var fs = require('fs');
require('dotenv').config();

var dir = './dump';
if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
}

var base = new Airtable({apiKey: process.env.APIKEY}).base(process.env.BASE);

base('🍩 Oral Histories').select({
    // Selecting the first 3 records in Worksheet:
    // maxRecords: 3,
    view: ".LOCMetadataView",
    cellFormat: "string",
    timeZone: "America/New_York",
    userLocale: "en-ca",
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
      "Youtube Publish Schedule",
      "Wikimedia Status",
      "Wiki Commons URL"
    ]
}).eachPage(function page(records, fetchNextPage) {
    // This function (`page`) will get called for each page of records.

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