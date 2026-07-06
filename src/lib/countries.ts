// Maps the free-text Country field to an ISO 3166-1 alpha-2 code so we can
// render a flag via country-flag-icons. Add more entries here as new
// countries show up in the data -- unmapped countries just render without a
// flag rather than breaking anything.
const COUNTRY_TO_ISO: Record<string, string> = {
  "united kingdom": "GB",
  "south africa": "ZA",
  australia: "AU",
  ireland: "IE",
  kenya: "KE",
  canada: "CA",
  ghana: "GH",
  nigeria: "NG",
};

export function countryToIso(country: string | null | undefined): string | null {
  if (!country) return null;
  return COUNTRY_TO_ISO[country.trim().toLowerCase()] ?? null;
}
