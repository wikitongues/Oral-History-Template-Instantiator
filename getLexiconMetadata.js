const Airtable = require('airtable');
const fs = require('fs');
const path = require('path');

const identifier = process.argv[2];
const repo = process.argv[3];
const destination = process.argv[4];
const fileIdentifier = process.argv[5];

require('dotenv').config({ path: repo + '/.env' });

const base = new Airtable({apiKey: process.env.APIKEY}).base(process.env.BASE);

const TABLE = 'Lexicons';
const VIEW = 'Public Archival View';
const CELL_FORMAT = 'string';
const TIME_ZONE = 'America/New_York';
const USER_LOCALE = 'en-ca';
const ID_FIELD = 'Identifier';

const FIELDS = [
  'Identifier',
  'Title',
  'Subject [Languages]',
  'Creator',
  'Description',
  'Date [Created]',
  'Subject [Source Language: Genealogy]',
  'Subject [Source Language: Continent]',
  'Subject [Source Language: Nation]',
  'Language [Source]',
  'Language [Source: ISO 639-3]',
  'Language [Source: Glottocode]',
  'Language [Source Dialect: Glottocode]',
  'Language [Source Macrolanguage: ISO 639-3]',
  'Language [Target]',
  'Language [Target: ISO 639-3]',
  'Language [Target: Glottocode]',
  'Language [Target Dialect: Glottocode]',
  'Language [Target Macrolanguage: ISO 639-3]',
  'Publisher',
  'Format [Medium]',
  'Format [Extent]',
  'Relation [Requires]',
  'Type',
  'Type [Document: LOC]',
  'Type [Document Category: LOC]',
  'Coverage [Nation]',
  'Coverage [Territory]',
  'Coverage [Dropbox]',
  'Coverage [Web]',
  'Relation [Is Version Of]',
  'Relation [Is Part Of]',
  'Rights'
];

base(TABLE).select({
  view: VIEW,
  cellFormat: CELL_FORMAT,
  timeZone: TIME_ZONE,
  userLocale: USER_LOCALE,
  filterByFormula: `${ID_FIELD}='${identifier}'`,
  fields: FIELDS
}).firstPage((err, records) => {
  if (err) {
    console.error(err);
    return process.exit(1);
  }
  if (records.length !== 1) {
    console.error(`${records.length} records found for identifier ${identifier}`);
    return process.exit(1);
  }
  const record = records[0];
  const content = FIELDS.map(field => `${field}: ${record.get(field)}`).join('\n');

  fs.writeFileSync(`${path.resolve(destination)}/${fileIdentifier}/${fileIdentifier}__metadata.txt`, content);
});
