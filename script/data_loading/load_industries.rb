# this script loads the list of NAICS sectors, as provided by ChatGPT

naics_sectors = [
  { code: "11", name: "Agriculture, Forestry, Fishing and Hunting" },
  { code: "21", name: "Mining, Quarrying, and Oil and Gas Extraction" },
  { code: "22", name: "Utilities" },
  { code: "23", name: "Construction" },
  { code: "31-33", name: "Manufacturing" },
  { code: "42", name: "Wholesale Trade" },
  { code: "44-45", name: "Retail Trade" },
  { code: "48-49", name: "Transportation and Warehousing" },
  { code: "51", name: "Information" },
  { code: "52", name: "Finance and Insurance" },
  { code: "53", name: "Real Estate and Rental and Leasing" },
  { code: "54", name: "Professional, Scientific, and Technical Services" },
  { code: "55", name: "Management of Companies and Enterprises" },
  { code: "56", name: "Administrative and Support and Waste Management and Remediation Services" },
  { code: "61", name: "Educational Services" },
  { code: "62", name: "Health Care and Social Assistance" },
  { code: "71", name: "Arts, Entertainment, and Recreation" },
  { code: "72", name: "Accommodation and Food Services" },
  { code: "81", name: "Other Services (except Public Administration)" },
  { code: "92", name: "Public Administration" }
]

Industry.insert_all(naics_sectors)
